import { isTauri } from "@tauri-apps/api/core";

import type { Options } from "youtube-player/dist/types";

import NativePlayer, { type NativePlaybackFormat } from "./NativePlayer";
import WebEmbedPlayer from "./WebEmbedPlayer";

export interface StreamPlayerFactoryOptions {
  nativeOptions: {
    format: NativePlaybackFormat;
  };
  webOptions?: Options;
}

interface StreamPlayerPair {
  musicPlayerStreamDevice: NativePlayer;
  musicPlayerWebCompatibilityDevice?: WebEmbedPlayer;
}

export default class StreamPlayerFactory {
  static create(options: StreamPlayerFactoryOptions): StreamPlayerPair {
    return {
      musicPlayerStreamDevice: new NativePlayer(options.nativeOptions.format),
      musicPlayerWebCompatibilityDevice: isTauri()
        ? new WebEmbedPlayer(options.webOptions)
        : undefined,
    };
  }
}
