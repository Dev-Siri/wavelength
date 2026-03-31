import { isTauri } from "@tauri-apps/api/core";
import { z } from "zod";

import type { StreamMetadata } from "$lib/schemas/stream";
import type { MusicPlaylistContextSource, QueueableMusic } from "./MusicQueue.svelte";
import type { PlayerEvent, StreamPlayer } from "./StreamPlayer";

import { localStorageKeys } from "$lib/constants/keys";
import { prefetchTrack } from "$lib/ipc/youtube";
import { punctuatify } from "$lib/utils/format";
import { reportStream, streamClient } from "$lib/utils/query-client";
import LocalMusicQueue from "./LocalMusicQueue.svelte";

const SIX_HOURS_MS = 6 * 60 * 60 * 1000;

/**
 * `StreamPlayerController` provides a Svelte interface to interact with the player.
 *
 * The controller manages the lifecycle of the underlying player itself to decouple
 * itself completely from the UI. This allows the UI itself to break and rebuild multiple
 * times on layout shifts and mobile adaptations without affecting the stream playback.
 */
export default class StreamPlayerController {
  public isPlaying = $state(false);
  public volume = $state(1);
  /** The total duration of the current loaded track.  */
  public duration = $state(0);
  /** The duration (in seconds) consumed. */
  public currentTime = $state(0);
  /** Percentage representing how much the StreamPlayer has completed of the stream. */
  public progress = $derived.by(() => {
    if (!this.duration) return 0;
    return (this.currentTime / this.duration) * 100;
  });
  public isMuted = $state(false);
  public streamMetadata = $state<StreamMetadata | null>(null);
  public outputSinkId = $state<string>("");

  private lastCreatedAt: Date | null = null;
  private didReport30sStream = false;

  public constructor(
    private streamPlayer: StreamPlayer,
    public queue = new LocalMusicQueue(),
  ) {
    this.attachEventListeners();
    this.syncPlayerSettings();
  }

  private handleOnPause = async () => {
    this.isPlaying = false;
    navigator.mediaSession.playbackState = "paused";
  };

  private handleOnPlay = async () => {
    // eslint-disable-next-line svelte/prefer-svelte-reactivity
    const now = new Date();

    const isExpired =
      this.lastCreatedAt && now.getTime() - this.lastCreatedAt.getTime() > SIX_HOURS_MS;
    if (isExpired) await this.reload();

    const totalDuration = await this.streamPlayer.getDuration();
    this.duration = totalDuration;
    this.isPlaying = true;
    navigator.mediaSession.playbackState = "playing";
  };

  private handleTimeUpdate = async (event: PlayerEvent<"timeupdate">) => {
    if (!this.queue.playingNow) return;

    // YouTube sometimes decides to return streams with double the actual content-length, especially on macOS.
    // The doubled part itself has no audio data, so it just makes the playback stop playing for a few minutes.
    //
    // To fix it, we assume extra seconds of length here, which when exceeded by the stream would mean that the
    // stream is definitely of the wrong length and we should use the duration provided in the music metadata instead.
    const INCORRECT_THRESHOLD = 15;
    const { duration, currentTime } = event.detail;

    const providedLength = Number(this.queue.playingNow.duration ?? 0);
    const isProbablyWrongLength = duration + INCORRECT_THRESHOLD > providedLength;

    if (isProbablyWrongLength) {
      this.duration = providedLength;
    } else {
      this.duration = duration;
    }

    if (this.currentTime > this.duration) {
      return this.handleOnEnded();
    }

    this.currentTime = currentTime;

    if (currentTime >= 30 && !this.didReport30sStream) {
      reportStream({ track: this.queue.playingNow, type: "play30s" });
      this.didReport30sStream = true;
    }
  };

  private handleLoaded = async (event: PlayerEvent<"loaded">) => {
    if (event.detail.metadata) {
      this.streamMetadata = event.detail.metadata;
    } else {
      this.streamMetadata = null;
    }
  };

  private handleOnEnded = async () => {
    if (this.queue.repeatMode === "one") return this.play();

    this.currentTime = 0;
    if (!this.queue?.playingNow) return;

    await this.pause();
    const nextTrack = this.queue.pickNext();
    if (nextTrack) await this.load(nextTrack);
  };

  private attachEventListeners() {
    this.streamPlayer.on("playing", this.handleOnPlay);
    this.streamPlayer.on("paused", this.handleOnPause);
    this.streamPlayer.on("ended", this.handleOnEnded);
    this.streamPlayer.on("timeupdate", this.handleTimeUpdate);
    this.streamPlayer.on("loaded", this.handleLoaded);
  }

  private async syncPlayerSettings() {
    const storedVolume = localStorage.getItem(localStorageKeys.volume);

    if (storedVolume) {
      const numericalVolume = Number(storedVolume);
      this.setVolume(numericalVolume > 1 ? 1 : numericalVolume);
    }
  }

  private async prefetchTracks() {
    const nextTracks = this.queue.nextTracks.slice(0, 2);
    if (!nextTracks.length) return;

    const prefetches: Promise<void>[] = [];

    for (const track of nextTracks) {
      const prefetch = async () => {
        void streamClient(`/collector/${track.videoId}`, z.string(), { method: "POST" });
        return prefetchTrack(track.videoId);
      };

      prefetches.push(prefetch());
    }

    return Promise.all(prefetches);
  }

  dispose() {
    this.streamPlayer.off("playing", this.handleOnPlay);
    this.streamPlayer.off("paused", this.handleOnPause);
    this.streamPlayer.off("ended", this.handleOnEnded);
    this.streamPlayer.off("timeupdate", this.handleTimeUpdate);
    this.streamPlayer.off("loaded", this.handleLoaded);
  }

  async load(
    track: QueueableMusic,
    context?: MusicPlaylistContextSource,
    startingSeconds?: number,
  ) {
    reportStream({ track, type: "playStart" });
    // eslint-disable-next-line svelte/prefer-svelte-reactivity
    this.lastCreatedAt = new Date();
    this.queue.playingNow = track;
    this.currentTime = 0;
    this.duration = 0;
    this.didReport30sStream = false;

    if (context) {
      this.queue.loadContext(context);
    }
    await this.streamPlayer.load(track.videoId, { startingSeconds, videoType: track.videoType });

    const { title, thumbnail, artists, album } = track;

    navigator.mediaSession.metadata = new MediaMetadata({
      title,
      artwork: thumbnail ? [{ src: thumbnail }] : [],
      artist: punctuatify(artists.map(artist => artist.title) ?? []),
      album: album?.title,
    });

    navigator.mediaSession.setActionHandler("pause", () => this.pause());
    navigator.mediaSession.setActionHandler("play", () => this.play());
    navigator.mediaSession.setActionHandler("nexttrack", () => this.next());
    navigator.mediaSession.setActionHandler("previoustrack", () => this.previous());

    if (context && isTauri()) {
      await this.prefetchTracks();
    }
  }

  async reload(preserveTime?: boolean) {
    if (!this.queue.playingNow) return;
    return this.load(this.queue.playingNow, undefined, preserveTime ? this.currentTime : 0);
  }

  async next() {
    if (this.duration <= 10 && this.queue.playingNow) {
      reportStream({ track: this.queue.playingNow, type: "skipFast" });
    }

    const nextTrack = this.queue.skipToNext();
    if (nextTrack) await this.load(nextTrack);
  }

  async previous() {
    const prevTrack = this.queue.skipToPrevious();
    if (prevTrack) await this.load(prevTrack);
  }

  async play() {
    if (this.progress === 100) {
      await this.seek(0);
      this.currentTime = 0;
    }

    await this.streamPlayer.play();
  }

  async pause() {
    await this.streamPlayer.pause();
  }

  async seek(to: number) {
    await this.streamPlayer.seek(to);
  }

  async setVolume(newVolume: number) {
    await this.streamPlayer.setVolume(newVolume);
    this.volume = newVolume;
    localStorage.setItem(localStorageKeys.volume, newVolume.toString());
  }

  async toggleMute() {
    if (this.isMuted) {
      await this.streamPlayer.unMute();
      this.isMuted = false;
    } else {
      await this.streamPlayer.mute();
      this.isMuted = true;
    }
  }
}
