import { isTauri } from "@tauri-apps/api/core";
import { get, set } from "idb-keyval";
import { z } from "zod";

import type { PlaylistVideoType } from "$lib/schemas/playlist";
import type { LoadedStream } from "./StreamPlayer";

import { playbackQualityBitrateMap } from "$lib/constants/settings";
import { getDownloadedSource, isDownloaded } from "$lib/ipc/download";
import { getSettings } from "$lib/ipc/settingsManager";
import { fetchHighestBitrateAudioStreamUrl } from "$lib/ipc/youtube";
import {
  hlsStreamSourceSchema,
  playabilityStatusResponseSchema,
  playabilityStatusSchema,
} from "$lib/schemas/stream";
import { streamClient } from "$lib/utils/query-client";
import StreamResolverCache from "./StreamResolverCache";

const streamResolverCache = new StreamResolverCache();

export default class StreamResolver {
  public static async fetch(videoId: string, videoType: PlaylistVideoType): Promise<LoadedStream> {
    const settings = await getSettings();
    // Always prefer 320kbps (Compressed) streaming on the web.
    const preferredQuality = isTauri() ? playbackQualityBitrateMap[settings.playbackQuality] : 320;

    const cachedStream = await streamResolverCache.getCachedUrl(videoId, preferredQuality);

    if (cachedStream) return cachedStream;

    if (videoType === "VIDEO_TYPE_UVIDEO") {
      return this.fetchFromTydle(videoId);
    }

    const playabilityStatus = await this.fetchStreamPlayabilityStatus(videoId);
    this.collectStream(videoId);

    if (playabilityStatus === "UNPLAYABLE") {
      return this.fetchFromTydle(videoId);
    }

    if (playabilityStatus === "UNAVAILABLE") {
      return this.fetchFromTydle(videoId);
    }

    const {
      source,
      metadata: { bitrate, codec, container, sampleRate },
    } = await streamClient(`/streams/${videoId}`, hlsStreamSourceSchema, {
      searchParams: { preferredQuality },
    });

    const loadedStream: LoadedStream = {
      url: source,
      metadata: {
        bitrate,
        codec,
        ext: container,
      },
      source: {
        sampleRate,
        name: "Wavelength (as HLS/m3u8)\nHTTP Live-Streaming (vnd.apple.mpegurl)",
        sourceType: "wavelength",
      },
    };

    streamResolverCache.saveToCache({ videoId, stream: loadedStream });
    return loadedStream;
  }

  public static async fetchDownload(videoId: string) {
    if (!isTauri()) return;

    const isAudioDownloaded = await isDownloaded(videoId);
    if (!isAudioDownloaded) return;

    const downloadedStream = await getDownloadedSource(videoId);
    return downloadedStream;
  }

  private static collectStream(videoId: string) {
    void streamClient(`/collector/${videoId}`, z.string(), { method: "POST" });
  }

  private static async fetchFromTydle(videoId: string): Promise<LoadedStream> {
    if (!isTauri()) {
      await streamClient(`/collector/${videoId}`, z.string(), { method: "POST" });
      const {
        source,
        metadata: { bitrate, codec, container, sampleRate },
      } = await streamClient(`/streams/${videoId}`, hlsStreamSourceSchema);

      return {
        url: source,
        metadata: {
          bitrate,
          codec,
          ext: container,
        },
        source: {
          name: "Wavelength (as HLS/m3u8)\nHTTP Live-Streaming (vnd.apple.mpegurl)",
          sampleRate,
          sourceType: "wavelength",
        },
      } satisfies LoadedStream;
    }

    const audioStream = await fetchHighestBitrateAudioStreamUrl(videoId);
    return {
      ...audioStream,
      source: {
        name: "YouTube (Direct Streaming)\nSourced by tydle.",
        sampleRate: 44_100,
        sourceType: "youtube",
      },
    };
  }

  private static async fetchStreamPlayabilityStatus(videoId: string) {
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
}
