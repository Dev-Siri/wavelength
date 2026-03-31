import createYouTubePlayer from "youtube-player";

import type { PlaylistVideoType } from "$lib/schemas/playlist";
import type { Options, YouTubePlayer } from "youtube-player/dist/types";

import { StreamPlayer } from "./StreamPlayer";

const TIME_UPDATE = 250;
const playerStates = {
  unstarted: -1,
  ended: 0,
  playing: 1,
  paused: 2,
  buffering: 3,
  videoCued: 5,
} as const;

export default class WebEmbedPlayer extends StreamPlayer {
  private player: YouTubePlayer | null = null;
  private timeUpdateInterval: number | null = null;

  public constructor(private options?: Options) {
    super();
  }

  async attach(
    /** The element where the `WebEmbedPlayer` will attach to. */
    playerElement?: HTMLDivElement,
  ) {
    if (!playerElement) throw new Error("`playerElement` not found.");
    this.player = createYouTubePlayer(playerElement, this.options);

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

  assertPlayer(): never {
    throw new Error("Player not initialized. Did you forget to call .attach()?");
  }

  async dispose() {
    if (!this.player) this.assertPlayer();

    if (this.timeUpdateInterval) clearInterval(this.timeUpdateInterval);
    return this.player.destroy();
  }

  async mute() {
    if (!this.player) this.assertPlayer();
    return this.player.mute();
  }

  unMute() {
    if (!this.player) this.assertPlayer();
    return this.player.unMute();
  }

  // Listen to events on the YouTube Player and dispatch them from WebEmbedPlayer.
  private forwardEvents() {
    if (!this.player) this.assertPlayer();
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

  async load(
    videoId: string,
    { startingSeconds }: { startingSeconds?: number; videoType?: PlaylistVideoType } = {},
  ) {
    if (!this.player) this.assertPlayer();
    await this.player.loadVideoById(videoId, startingSeconds);
    this.dispatchEvent(this.createEvent("loaded", { metadata: null }));
  }

  async pause() {
    if (!this.player) this.assertPlayer();
    await this.player.pauseVideo();
    this.dispatchEvent(this.createEvent("paused"));
  }

  async play() {
    if (!this.player) this.assertPlayer();
    await this.player.playVideo();
    this.dispatchEvent(this.createEvent("playing"));
  }

  async seek(to: number) {
    if (!this.player) this.assertPlayer();
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
    if (!this.player) this.assertPlayer();
    return this.player.getCurrentTime();
  }

  async getDuration() {
    if (!this.player) this.assertPlayer();
    return this.player.getDuration();
  }

  async setVolume(newVolume: number) {
    if (!this.player) this.assertPlayer();
    return this.player.setVolume(newVolume * 100);
  }
}
