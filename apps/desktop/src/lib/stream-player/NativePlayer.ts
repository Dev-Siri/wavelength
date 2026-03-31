import Hls from "hls.js";
import { get, set } from "idb-keyval";
import { z } from "zod";

import { playbackQualityBitrateMap } from "$lib/constants/settings";
import { STREAM_PLAYBACK_URL } from "$lib/constants/utils";
import { getDownloadedSource, isDownloaded } from "$lib/ipc/download";
import { getSettings } from "$lib/ipc/settingsManager";
import {
  fetchHighestBitrateAudioStreamUrl,
  fetchHighestBitrateVideoStreamUrl,
} from "$lib/ipc/youtube";
import type { PlaylistVideoType } from "$lib/schemas/playlist";
import {
  hlsStreamSourceSchema,
  playabilityStatusResponseSchema,
  playabilityStatusSchema,
  type Stream,
  type StreamMetadata,
} from "$lib/schemas/stream";
import { streamClient } from "$lib/utils/query-client";
import { isTauri } from "@tauri-apps/api/core";
import { StreamPlayer } from "./StreamPlayer";

export const NATIVE_PLAYBACK_FORMAT = {
  AUDIO: "audio",
  VIDEO: "video",
} as const;

export type NativePlaybackFormatMap = typeof NATIVE_PLAYBACK_FORMAT;
export type NativePlaybackFormat = NativePlaybackFormatMap[keyof NativePlaybackFormatMap];

export default class NativePlayer extends StreamPlayer {
  private playerElement?: HTMLMediaElement | null;
  private hls?: Hls | null;

  public constructor(private format: NativePlaybackFormat) {
    super();
  }

  playerWarn() {
    console.warn("Player not initialized. Did you forget to call .attach()?");
  }

  private playingHandler = () => this.dispatchEvent(this.createEvent("playing"));
  private pausedHandler = () => this.dispatchEvent(this.createEvent("paused"));
  private endedHandler = () => this.dispatchEvent(this.createEvent("ended"));
  private timeUpdateHandler = async () => {
    const currentTime = await this.getCurrentTime();
    const duration = await this.getDuration();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime,
        duration,
      }),
    );
  };

  async attach(
    /** The element where the `NativePlayer` will attach to with all event-listeners. */
    playerElement?: HTMLMediaElement,
  ) {
    if (!playerElement) return;

    this.playerElement = playerElement;

    this.forwardEvents();
  }

  async dispose() {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.removeEventListener("playing", this.playingHandler);
    this.playerElement.removeEventListener("pause", this.pausedHandler);
    this.playerElement.removeEventListener("ended", this.endedHandler);
    this.playerElement.removeEventListener("timeupdate", this.timeUpdateHandler);

    this.hls?.destroy();

    this.playerElement = null;
    this.hls = null;
  }

  async mute() {
    if (!this.playerElement) return this.playerWarn();
    this.playerElement.muted = true;
  }

  async unMute() {
    if (!this.playerElement) return this.playerWarn();
    this.playerElement.muted = false;
  }

  private forwardEvents() {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.addEventListener("playing", this.playingHandler);
    this.playerElement.addEventListener("pause", this.pausedHandler);
    this.playerElement.addEventListener("ended", this.endedHandler);
    this.playerElement.addEventListener("timeupdate", this.timeUpdateHandler);
  }

  private async fetchDownloadedSource(videoId: string) {
    if (this.format === NATIVE_PLAYBACK_FORMAT.VIDEO) return;

    const isAudioDownloaded = await isDownloaded(videoId);
    if (!isAudioDownloaded) return;

    const downloadedStream = await getDownloadedSource(videoId);
    return downloadedStream;
  }

  private async fetchStreamPlayabilityStatus(videoId: string) {
    const playabilityStatusKey = `${videoId}-playability-status`;
    const cachedPlayabilityStatus = await get(playabilityStatusKey);
    const cachedPlayabilityStatusParsed = playabilityStatusSchema
      .optional()
      .parse(cachedPlayabilityStatus);

    if (cachedPlayabilityStatusParsed === "PLAYABLE") {
      return cachedPlayabilityStatusParsed;
    }

    const playabilityStatusResponse = await streamClient(
      `/streams/${videoId}/playability-status`,
      playabilityStatusResponseSchema,
    );

    if (playabilityStatusResponse.playabilityStatus === "PLAYABLE") {
      await set(playabilityStatusKey, playabilityStatusResponse.playabilityStatus);
    }

    return playabilityStatusResponse.playabilityStatus;
  }

  private collectStream(videoId: string) {
    void streamClient(`/collector/${videoId}`, z.string(), { method: "POST" });
  }

  private async fetchStreamSource(videoId: string, videoType: PlaylistVideoType) {
    switch (this.format) {
      case NATIVE_PLAYBACK_FORMAT.VIDEO: {
        const videoStream = await fetchHighestBitrateVideoStreamUrl(videoId);
        return videoStream;
      }
      case NATIVE_PLAYBACK_FORMAT.AUDIO: {
        async function fetchFromTydle() {
          if (!isTauri()) {
            throw new Error(
              "Song is unavailable for native audio playback. Wait for a few minutes while Wavelength ensures playability, then try again.",
            );
          }

          const audioStream = await fetchHighestBitrateAudioStreamUrl(videoId);
          return audioStream;
        }

        if (videoType === "VIDEO_TYPE_UVIDEO") {
          return await fetchFromTydle();
        }

        const playabilityStatus = await this.fetchStreamPlayabilityStatus(videoId);
        this.collectStream(videoId);

        if (playabilityStatus === "UNPLAYABLE") {
          return await fetchFromTydle();
        }

        if (playabilityStatus === "UNAVAILABLE") {
          return await fetchFromTydle();
        }

        const settings = await getSettings();

        const {
          source,
          metadata: { bitrate, codec, container },
        } = await streamClient(`/streams/${videoId}`, hlsStreamSourceSchema, {
          searchParams: {
            preferredQuality: playbackQualityBitrateMap[settings.playbackQuality],
          },
        });

        return {
          url: source,
          metadata: {
            bitrate,
            codec: { acodec: codec },
            ext: container,
            source: "Wavelength (HLS/m3u8: vnd.apple.mpegurl)",
          },
        } satisfies Stream;
      }
    }
  }

  private async sourceEnsureStreamCompatibility(url: string, source: string) {
    if (!this.playerElement) return this.playerWarn();
    const isStreamHls = source.includes("Wavelength");

    if (!isStreamHls) {
      this.playerElement.src = `${STREAM_PLAYBACK_URL}/stream-playback?url=${encodeURIComponent(url)}`;
      return;
    }

    // Current browser/tauri-webview natively supports HLS so we can directly play it with src="url".
    if (this.playerElement.canPlayType("application/vnd.apple.mpegurl")) {
      this.playerElement.src = url;
    } else if (Hls.isSupported()) {
      this.hls = new Hls();
      this.hls.loadSource(url);
      this.hls.attachMedia(this.playerElement);
    }
  }

  async load(
    videoId: string,
    {
      startingSeconds,
      videoType = "VIDEO_TYPE_TRACK",
    }: { startingSeconds?: number; videoType?: PlaylistVideoType } = {},
  ) {
    if (!this.playerElement) return this.playerWarn();

    await this.pause();
    this.playerElement.src = "";
    this.playerElement.autoplay = true;

    const downloadedStreamUrl = isTauri() ? await this.fetchDownloadedSource(videoId) : null;
    let metadata: StreamMetadata | null = null;

    if (downloadedStreamUrl) {
      this.playerElement.src = `${STREAM_PLAYBACK_URL}/local-playback?url=${encodeURIComponent(downloadedStreamUrl)}`;
    } else {
      const stream = await this.fetchStreamSource(videoId, videoType);
      if (!stream) return;

      metadata = stream.metadata;

      await this.sourceEnsureStreamCompatibility(stream.url, stream.metadata.source);
    }

    if (startingSeconds) this.playerElement.currentTime = startingSeconds;

    // For some reason in non-Tauri environments, autoplay doesn't work on click of play.
    // So this is a workaround to trigger the "playing" event which in turn updates the UI play/pause button state.
    if (!isTauri()) {
      await this.play();
    }

    this.dispatchEvent(this.createEvent("loaded", { metadata }));
  }

  async pause() {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.pause();
    this.dispatchEvent(this.createEvent("paused"));
  }

  async play() {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.play();
    this.dispatchEvent(this.createEvent("playing"));
  }

  async seek(to: number) {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.currentTime = to;
    const duration = await this.getDuration();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime: to,
        duration,
      }),
    );
  }

  async getCurrentTime() {
    if (!this.playerElement) {
      this.playerWarn();
      return 0;
    }

    const time = this.playerElement.currentTime;
    return isNaN(time) ? 0 : time;
  }

  async getDuration() {
    if (!this.playerElement) {
      this.playerWarn();
      return 0;
    }

    const duration = this.playerElement.duration;
    return isNaN(duration) ? 0 : duration;
  }

  async setVolume(newVolume: number) {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.volume = newVolume;
  }
}
