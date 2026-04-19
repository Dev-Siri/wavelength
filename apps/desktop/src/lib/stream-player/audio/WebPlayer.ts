import Hls, { type HlsConfig } from "hls.js";

import type { PlaylistVideoType } from "$lib/schemas/playlist";

import { STREAM_PLAYBACK_URL } from "$lib/constants/utils";
import { StreamPlayer, type LoadedStream } from "./StreamPlayer";
import StreamResolver from "./StreamResolver";

const HLS_CONFIG: Partial<HlsConfig> = {
  backBufferLength: 10,
  highBufferWatchdogPeriod: 2,
  nudgeOffset: 0.1,
  nudgeMaxRetry: 5,
  maxFragLookUpTolerance: 0.25,
  maxBufferLength: 210,
  maxBufferSize: 200 * 1000 * 1000,
  liveSyncDurationCount: 1,
  startFragPrefetch: true,
  progressive: true,
};

export default class WebPlayer extends StreamPlayer {
  private playerElement?: HTMLMediaElement | null;
  private hls?: Hls | null;
  private targetVolume = 1;

  private playerWarn() {
    console.warn("Player not initialized. Did you forget to call .attach()?");
  }

  private playingHandler = () => this.dispatchEvent(this.createEvent("playing"));
  private pausedHandler = () => this.dispatchEvent(this.createEvent("paused"));
  private endedHandler = () => this.dispatchEvent(this.createEvent("ended"));
  private timeUpdateHandler = () => {
    const bufferedTime = this.getBufferedTime();
    const currentTime = this.getCurrentTime();
    const duration = this.getDuration();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime,
        duration,
        bufferedTime,
      }),
    );
  };

  private async fadeVolume(target: number) {
    if (document.hidden) return;
    return new Promise<void>(resolve => {
      if (!this.playerElement) return;

      const FADE_DURATION = 300;

      const start = this.playerElement.volume;
      const diff = target - start;
      const startTime = performance.now();

      const tick = (now: number) => {
        if (!this.playerElement) return;
        const progress = Math.min((now - startTime) / FADE_DURATION, 1);

        this.playerElement.volume = start + diff * progress;

        if (progress < 1) {
          requestAnimationFrame(tick);
        } else {
          this.playerElement.volume = target;
          resolve();
        }
      };

      requestAnimationFrame(tick);
    });
  }

  async attach(
    /** The element where the `WebPlayer` will attach to with all event-listeners. */
    playerElement?: HTMLMediaElement,
  ) {
    if (!playerElement) return;
    if (this.playerElement) await this.dispose();

    this.playerElement = playerElement;
    if (Hls.isSupported()) {
      this.hls = new Hls(HLS_CONFIG);
      this.hls.attachMedia(this.playerElement);
    }

    this.forwardEvents();
  }

  async dispose() {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.removeEventListener("playing", this.playingHandler);
    this.playerElement.removeEventListener("pause", this.pausedHandler);
    this.playerElement.removeEventListener("ended", this.endedHandler);
    this.playerElement.removeEventListener("timeupdate", this.timeUpdateHandler);

    // clear buffer
    this.playerElement.src = "";
    this.playerElement.load();

    this.hls?.stopLoad();
    this.hls?.detachMedia();
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

  private async sourceEnsureStreamCompatibility({ url, source: { sourceType } }: LoadedStream) {
    if (!this.playerElement) return this.playerWarn();

    if (sourceType === "youtube") {
      this.hls?.destroy();
      this.hls = null;
      this.playerElement.src = `${STREAM_PLAYBACK_URL}/stream-playback?url=${encodeURIComponent(url)}`;
      return;
    }

    if (!this.hls && Hls.isSupported()) {
      this.hls = new Hls(HLS_CONFIG);
      this.hls.attachMedia(this.playerElement);
    }
    this.hls?.loadSource(url);
  }

  async load(
    videoId: string,
    {
      startingSeconds,
      videoType = "VIDEO_TYPE_TRACK",
    }: { startingSeconds?: number; videoType?: PlaylistVideoType } = {},
  ) {
    if (!this.playerElement) return this.playerWarn();
    if (this.playerElement.volume !== this.targetVolume) {
      // Sync player volume with expected in-case it breaks.
      this.playerElement.volume = this.targetVolume;
    }

    this.playerElement.pause();
    this.playerElement.autoplay = true;

    const downloadedStreamUrl = await StreamResolver.fetchDownload(videoId);
    let loadedStream: LoadedStream | null = null;

    if (downloadedStreamUrl) {
      this.playerElement.src = `${STREAM_PLAYBACK_URL}/local-playback?url=${encodeURIComponent(downloadedStreamUrl)}`;
    } else {
      const stream = await StreamResolver.fetch(videoId, videoType);
      if (!stream) return;

      loadedStream = stream;
      await this.sourceEnsureStreamCompatibility(stream);
    }

    if (loadedStream?.source.sourceType === "wavelength") {
      this.hls?.startLoad(startingSeconds ?? 0);
    } else {
      this.playerElement.currentTime = startingSeconds ?? 0;
    }

    this.playerElement.play();

    this.dispatchEvent(this.createEvent("loaded", { stream: loadedStream }));
  }

  async pause() {
    if (!this.playerElement) return this.playerWarn();

    if (!document.hidden && this.playerElement.currentTime > 2) {
      await this.fadeVolume(0);
    }
    this.playerElement.pause();
  }

  async play() {
    if (!this.playerElement) return this.playerWarn();

    try {
      const shouldFade = !document.hidden && this.playerElement.currentTime > 2;

      if (shouldFade) {
        this.playerElement.volume = 0;
      } else {
        // ensure volume is correct on fresh loads / early playback
        this.playerElement.volume = this.targetVolume;
      }

      await this.playerElement.play();

      if (shouldFade) {
        this.fadeVolume(this.targetVolume);
      }
    } catch {
      this.playerElement.volume = this.targetVolume;
    }
  }

  async seek(to: number) {
    if (!this.playerElement) return this.playerWarn();

    this.playerElement.currentTime = to;
    const duration = this.getDuration();
    const bufferedTime = this.getBufferedTime();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime: to,
        duration,
        bufferedTime,
      }),
    );
  }

  getCurrentTime() {
    if (!this.playerElement) {
      this.playerWarn();
      return 0;
    }

    const time = this.playerElement.currentTime;
    return isNaN(time) || !isFinite(time) ? 0 : time;
  }

  getDuration() {
    if (!this.playerElement) {
      this.playerWarn();
      return 0;
    }

    const duration = this.playerElement.duration;
    return isNaN(duration) || !isFinite(duration) ? 0 : duration;
  }

  getBufferedTime() {
    if (!this.playerElement) return 0;

    const buffered = this.playerElement.buffered;
    if (!buffered.length) return 0;

    return buffered.end(buffered.length - 1);
  }

  setVolume(newVolume: number) {
    if (!this.playerElement) return this.playerWarn();

    this.targetVolume = newVolume;
    this.playerElement.volume = newVolume;
  }
}
