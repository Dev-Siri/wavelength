import { isTauri } from "@tauri-apps/api/core";

import type { PlayerBindingTarget } from "./musicPlayer";
import type { StreamPlayer } from "./StreamPlayer";

export function bindPreviewPlayer(
  previewStreamingDevice: StreamPlayer,
  { native, webEmbed }: Partial<PlayerBindingTarget>,
) {
  if (isTauri()) {
    previewStreamingDevice.attach(native);
  } else {
    previewStreamingDevice.attach(webEmbed);
  }
}
