import createYouTubePlayer from "youtube-player";

import type { YouTubePlayer } from "youtube-player/dist/types";
import type VideoStreamPlayer from "./VideoStreamPlayer";

// Sync music video every 15 seconds.
const SYNC_THRESHOLD = 15;

export default class WebVideoStreamPlayer implements VideoStreamPlayer {
  private playerElement?: HTMLDivElement | null;
  private player?: YouTubePlayer | null;

  private lastSyncTime?: number | null = null;

  private playerWarn() {
    console.warn("Preview player not initialized. Did you forget to call .attach()?");
  }

  async pause() {
    if (!this.player) return this.playerWarn();
    return this.player.pauseVideo();
  }

  async play() {
    if (!this.player) return this.playerWarn();
    return this.player.playVideo();
  }

  async sync(audioTime: number) {
    if (!this.player) return this.playerWarn();
    if (!this.lastSyncTime) {
      this.lastSyncTime = audioTime;
      return this.player.seekTo(audioTime, true);
    }

    if (Math.abs(this.lastSyncTime - audioTime) > SYNC_THRESHOLD) {
      this.lastSyncTime = audioTime;
      return this.player.seekTo(audioTime, true);
    }
  }

  attach(playerElement?: HTMLDivElement) {
    if (!playerElement) throw new Error("`playerElement` not found.");
    this.playerElement = playerElement;
  }

  async show(videoId: string) {
    if (!this.playerElement) return this.playerWarn();

    this.player = createYouTubePlayer(this.playerElement, {
      playerVars: {
        loop: 1,
        playlist: videoId,
        autoplay: 0,
        controls: 0,
        disablekb: 1,
        playsinline: 1,
      },
    });

    return this.player.mute();
  }

  dispose() {
    this.player?.destroy();
    this.player = null;
  }
}
