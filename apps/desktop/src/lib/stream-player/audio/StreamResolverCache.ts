import { del, get, set } from "idb-keyval";

import type { PlaybackQualityBitrate } from "$lib/constants/settings";
import type { LoadedStream } from "./StreamPlayer";

export type StreamCacheKey = `streamCache:${string}:${string}`;
export interface CachedStream {
  stream: LoadedStream;
  expiration: number;
}

const SIX_HOURS_MS = 6 * 60 * 60 * 1000;

export default class StreamResolverCache {
  private buildCacheKey({
    videoId,
    bitrate,
  }: {
    videoId: string;
    bitrate: PlaybackQualityBitrate;
  }): StreamCacheKey {
    return `streamCache:${videoId}:${bitrate};`;
  }

  async getCachedUrl(videoId: string, bitrate: PlaybackQualityBitrate) {
    const key = this.buildCacheKey({ videoId, bitrate });
    const cachedStream = await get<CachedStream>(key);

    if (cachedStream) {
      if (cachedStream.expiration > Date.now()) {
        return cachedStream.stream;
      } else {
        del(key);
      }
    }
  }

  saveToCache({ stream, videoId }: { stream: LoadedStream; videoId: string }) {
    set(`${videoId}:${stream.metadata.bitrate}`, {
      stream,
      expiration: Date.now() + SIX_HOURS_MS,
    });
  }
}
