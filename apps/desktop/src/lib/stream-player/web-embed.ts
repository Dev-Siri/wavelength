import createYouTubePlayer from "youtube-player";

import type { Options, YouTubePlayer } from "youtube-player/dist/types";

import { StreamPlayer } from "./player";

const TIME_UPDATE = 250;
const playerStates = {
  unstarted: -1,
  ended: 0,
  playing: 1,
  paused: 2,
  buffering: 3,
  videoCued: 5,
} as const;

export class WebEmbedPlayer extends StreamPlayer {
  private player: YouTubePlayer;
  private timeUpdateInterval: number;

  public constructor(
    /** The element where the `WebEmbedPlayer` will attach to. */
    public playerElement: HTMLDivElement,
    public options?: Options,
  ) {
    super();
    this.player = createYouTubePlayer(playerElement, options);
    this.forwardEvents();
    this.timeUpdateInterval = setInterval(async () => {
      const [currentTime, duration] = await Promise.all([
        this.getCurrentTime(),
        this.getDuration(),
      ]);

      this.dispatchEvent(
        this.createEvent("timeupdate", {
          duration,
          currentTime,
        }),
      );
    }, TIME_UPDATE);
  }

  async dispose() {
    clearInterval(this.timeUpdateInterval);
    return this.player.destroy();
  }

  async mute() {
    return this.player.mute();
  }

  unMute() {
    return this.player.unMute();
  }

  // Listen to events on the YouTube Player and dispatch them from WebEmbedPlayer.
  private forwardEvents() {
    this.player.on("stateChange", e => {
      switch (e.data) {
        case playerStates.playing:
          this.dispatchEvent(this.createEvent("playing"));
          break;
        case playerStates.paused:
          this.dispatchEvent(this.createEvent("paused"));
          break;
        case playerStates.ended:
          this.dispatchEvent(this.createEvent("ended"));
          break;
      }
    });
  }

  async load(videoId: string, startingSeconds?: number) {
    await this.player.loadVideoById(videoId, startingSeconds);
    this.dispatchEvent(this.createEvent("loaded"));
  }

  async pause() {
    await this.player.pauseVideo();
    this.dispatchEvent(this.createEvent("paused"));
  }

  async play() {
    await this.player.playVideo();
    this.dispatchEvent(this.createEvent("playing"));
  }

  async seek(to: number) {
    await this.player.seekTo(to, true);
    const duration = await this.getDuration();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime: to,
        duration,
      }),
    );
  }

  async getCurrentTime() {
    return this.player.getCurrentTime();
  }

  async getDuration() {
    return this.player.getDuration();
  }

  async setVolume(newVolume: number) {
    return this.player.setVolume(newVolume * 100);
  }
}
