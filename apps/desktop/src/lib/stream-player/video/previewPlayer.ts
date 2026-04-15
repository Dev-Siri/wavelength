import { isTauri } from "@tauri-apps/api/core";

import type VideoStreamPlayer from "./VideoStreamPlayer";

export interface VideoStreamPlayerBindingTarget {
  native: HTMLVideoElement;
  webEmbed: HTMLDivElement;
}

export function bindPreviewPlayer(
  previewStreamingDevice: VideoStreamPlayer,
  { native, webEmbed }: Partial<VideoStreamPlayerBindingTarget>,
) {
  if (isTauri()) {
    previewStreamingDevice.attach(native);
  } else {
    previewStreamingDevice.attach(webEmbed);
  }
}
