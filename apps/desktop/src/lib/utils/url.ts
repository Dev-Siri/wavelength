import { isTauri } from "@tauri-apps/api/core";
import { openUrl as openUrlNative } from "@tauri-apps/plugin-opener";

export function getUpscaledAlbumUrl(albumUrl: string) {
  return albumUrl.replace("h120-", "h768-").replace("w120-", "w768-");
}

export async function openUrl(url: string) {
  if (isTauri()) {
    return await openUrlNative(url);
  }

  window.open(url);
}
