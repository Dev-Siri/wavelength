import type { StreamPlayer } from "./StreamPlayer";

import WebPlayer from "./WebPlayer";

export default class StreamPlayerFactory {
  static create(): StreamPlayer {
    return new WebPlayer();
  }
}
