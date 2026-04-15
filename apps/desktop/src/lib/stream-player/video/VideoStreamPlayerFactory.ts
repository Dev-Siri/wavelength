import { isTauri } from "@tauri-apps/api/core";

import type VideoStreamPlayer from "./VideoStreamPlayer";

import DesktopVideoStreamPlayer from "./DesktopVideoStreamPlayer";
import WebVideoStreamPlayer from "./WebVideoStreamPlayer";

export default class VideoStreamPlayerFactory {
  static create(): VideoStreamPlayer {
    if (isTauri()) {
      return new DesktopVideoStreamPlayer();
    }
    return new WebVideoStreamPlayer();
  }
}
