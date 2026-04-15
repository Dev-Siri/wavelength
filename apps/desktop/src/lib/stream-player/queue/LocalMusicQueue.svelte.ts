/* eslint-disable svelte/prefer-svelte-reactivity */
import { automixTracksResponse } from "$lib/schemas/music-track";
import type { PlaylistVideoType } from "$lib/schemas/playlist";
import { backendClient, reportErrorToBackend } from "$lib/utils/query-client";
import { shuffle } from "$lib/utils/shuffle";

import type {
  AutomixContext,
  MusicPlaylistContext,
  MusicPlaylistContextSource,
  MusicQueue,
  MusicRepeatMode,
  PickDirection,
  QueueableMusic,
} from "./MusicQueue";

export default class LocalMusicQueue implements MusicQueue {
  public playingNow?: QueueableMusic | null = $state(null);
  public queue: QueueableMusic[] = $state([]);
  public repeatMode = $state<MusicRepeatMode>("none");
  public shuffleEnabled = $state(false);
  /**
   * The source from where the queue will continuously pick from
   * In case of different sources, the operation to get the tracks for each will also
   * be different. By default
   */
  private playlistContext = $state<MusicPlaylistContext>({
    source: { type: "none" },
    queue: [],
  });
  private shuffledContext: QueueableMusic[] = $state([]);
  private _automixedTracksContext = $state<AutomixContext | null>(null);
  private _playingNowIndex = $derived.by(() =>
    this.readyContextQueue.findIndex(music => music.videoId === this.playingNow?.videoId),
  );
  private _nextTracks = $derived.by(() => {
    if (this.playingNowIndex === -1) return [];

    const tracksAfterCurrentPlaying = this.readyContextQueue.slice(this.playingNowIndex + 1);
    return tracksAfterCurrentPlaying;
  });
  public readyContextQueue: QueueableMusic[] = $derived(
    this.shuffleEnabled ? this.shuffledContext : this.playlistContext.queue,
  );

  get playlistContextSource() {
    return this.playlistContext.source;
  }

  get automixedTracks() {
    return this._automixedTracksContext?.queue ?? [];
  }

  get nextTracks() {
    if (
      this.repeatMode === "none" &&
      this.playlistContext.source.type === "playlist" &&
      this.playingNowIndex === this.readyContextQueue.length - 1
    ) {
      return [];
    }

    return this._nextTracks;
  }

  get playingNowIndex() {
    return this._playingNowIndex;
  }

  cycleRepeatMode() {
    if (this.repeatMode === "none") {
      this.repeatMode = "all";
    } else if (this.repeatMode === "all") {
      this.repeatMode = "one";
    } else {
      if (this.playlistContext.source.type === "playlist") this.automixTracks();
      this.repeatMode = "none";
    }
  }

  enableShuffle() {
    this.shuffleEnabled = true;
    this.shuffledContext = shuffle(this.playlistContext.queue);
  }

  disableShuffle() {
    this.shuffleEnabled = false;
    this.shuffledContext = [];
  }

  loadContext(source: MusicPlaylistContextSource) {
    this._automixedTracksContext = null;
    this.playlistContext = {
      ...this.playlistContext,
      source,
    };

    if (source.type !== "none" && source.type !== "downloads") {
      this.playlistContext.queue = source.offlineTracks ?? [];
    }

    if (source.type === "none" || (source.type === "playlist" && this.repeatMode === "none")) {
      this.automixTracks();
    }

    if (this.shuffleEnabled) this.shuffledContext = shuffle(this.playlistContext.queue);
  }

  addToQueue(track: QueueableMusic) {
    this.queue = [track, ...this.queue];
  }

  removeFromQueue(videoId: string) {
    const filteredQueue = this.queue.filter(track => track.videoId !== videoId);
    this.queue = filteredQueue;
  }

  skipToPrevious() {
    const source = this.getActiveSource();

    if (source === "automix") {
      const prev = this.pickFromList(this._automixedTracksContext?.queue ?? [], "previous");

      if (prev) {
        this.setPlayingNow(prev);
        return prev;
      }

      const contextPrev = this.pickInContext("previous");
      this.setPlayingNow(contextPrev);
      return contextPrev;
    }

    if (source === "queue") {
      const prev = this.pickInQueue("previous", false);
      if (prev) {
        this.setPlayingNow(prev);
        return prev;
      }

      const contextPrev = this.pickInContext("previous");
      this.setPlayingNow(contextPrev);
      return contextPrev;
    }

    const prev = this.pickInContext("previous");

    if (!prev) return null;

    this.setPlayingNow(prev);
    return prev;
  }

  skipToNext() {
    const nextInQueue = this.pickInQueue("next", false);
    if (nextInQueue) {
      this.setPlayingNow(nextInQueue);
      return nextInQueue;
    }

    const nextPick = this.pickInContext("next");
    if (nextPick) {
      this.setPlayingNow(nextPick);
      return nextPick;
    }

    const isAtEndOfContext = this.playingNowIndex === this.readyContextQueue.length - 1;

    if (isAtEndOfContext && this.repeatMode === "none") {
      const nextAutomixedPick = this.pickInAutomixContext("next");
      this.setPlayingNow(nextAutomixedPick);
      return nextAutomixedPick;
    }
  }

  pickNext() {
    const nextInQueue = this.pickInQueue("next", true);
    if (nextInQueue) {
      this.setPlayingNow(nextInQueue);
      return nextInQueue;
    }

    const nextPick = this.pickInContext("next");
    if (nextPick) {
      this.setPlayingNow(nextPick);
      return nextPick;
    }

    const isAtEndOfContext = this.playingNowIndex === this.readyContextQueue.length - 1;

    if (isAtEndOfContext && this.repeatMode === "none") {
      const nextAutomixedPick = this.pickInAutomixContext("next");
      this.setPlayingNow(nextAutomixedPick);
      return nextAutomixedPick;
    }
  }

  async automixTracks() {
    try {
      let trackForAutomix: QueueableMusic | null | undefined = this.queue.findLast(
        track => track.videoType === "VIDEO_TYPE_TRACK",
      );
      if (!trackForAutomix && this.playingNow?.videoType === "VIDEO_TYPE_TRACK")
        trackForAutomix = this.playingNow;

      if (!trackForAutomix) return;

      const automixedTracks = await backendClient(
        `/music/track/${trackForAutomix.videoId}/automix`,
        automixTracksResponse,
      );

      const existing = this._automixedTracksContext?.queue ?? [];
      const incoming = automixedTracks.tracks.slice(1).map(track => ({
        ...track,
        videoType: "VIDEO_TYPE_TRACK" as PlaylistVideoType,
      }));

      const seen = new Set<string>();
      const merged = [...this.queue, ...this.readyContextQueue, ...existing, ...incoming];

      const queue = merged.filter(track => {
        if (seen.has(track.videoId)) return false;

        seen.add(track.videoId);
        return true;
      });

      this._automixedTracksContext = {
        automixedVideoId: trackForAutomix.videoId,
        queue,
      };
    } catch (err) {
      reportErrorToBackend({
        error: err,
        source: "(private) LocalMusicQueue.automixTracks()",
      });
    }
  }

  private pickFromList(list: QueueableMusic[], position: PickDirection) {
    if (!this.playingNow) return null;

    const index = list.findIndex(t => t.videoId === this.playingNow!.videoId);
    if (index === -1) return null;

    const isAtEdge = position === "next" ? index === list.length - 1 : index === 0;

    if (isAtEdge) return null;

    const nextIndex = position === "next" ? index + 1 : index - 1;
    return list[nextIndex];
  }

  private getActiveSource(): "queue" | "context" | "automix" {
    if (!this.playingNow) return "context";

    if (this.queue.some(t => t.videoId === this.playingNow!.videoId)) {
      return "queue";
    }

    if (this._automixedTracksContext?.queue.some(t => t.videoId === this.playingNow!.videoId)) {
      return "automix";
    }

    return "context";
  }

  private setPlayingNow(track: QueueableMusic | null | undefined) {
    if (!track) return;
    if (this.playingNow?.videoId === track.videoId) return;

    this.playingNow = track;
  }

  private pickInContext(position: PickDirection) {
    const isAtEdge =
      position === "next"
        ? this.readyContextQueue.length - 1 === this.playingNowIndex
        : this.playingNowIndex === 0;

    const positionedTrack =
      position === "next" ? this.playingNowIndex + 1 : this.playingNowIndex - 1;
    const queueStartIndex = position === "next" ? 0 : this.readyContextQueue.length - 1;
    const pickIndex = isAtEdge ? queueStartIndex : positionedTrack;

    if (this.repeatMode === "all" || (position === "next" && !isAtEdge)) {
      return this.readyContextQueue[pickIndex];
    }
  }

  private pickInAutomixContext(position: PickDirection) {
    if (!this._automixedTracksContext) return null;
    const automixIndex = this._automixedTracksContext.queue.findIndex(
      t => t.videoId === this.playingNow?.videoId,
    );

    const isAtEdge =
      position === "next"
        ? automixIndex === this._automixedTracksContext.queue.length - 1
        : automixIndex === 0;

    const remainingTracks =
      position === "next"
        ? this._automixedTracksContext.queue.length - 1 - automixIndex
        : automixIndex;

    const isCorrectContextForAutomix =
      this.playlistContext.source.type === "none" ||
      (this.playlistContext.source.type === "playlist" && this.repeatMode === "none");

    if (remainingTracks < 3 && isCorrectContextForAutomix) {
      this.automixTracks();
    }

    const positionedTrack = position === "next" ? automixIndex + 1 : automixIndex - 1;
    const queueStartIndex = position === "next" ? 0 : this._automixedTracksContext.queue.length - 1;
    const pickIndex = isAtEdge ? queueStartIndex : positionedTrack;

    if (this.repeatMode === "all" || (position === "next" && !isAtEdge)) {
      return this._automixedTracksContext.queue[pickIndex];
    }
  }

  private pickInQueue(position: PickDirection, pop?: boolean) {
    // When the queue is empty.
    if (!this.queue.length) return;

    const queueStartIndex = position === "next" ? 0 : this.queue.length - 1;
    const playingNow = this.playingNow;
    // If the user isn't playing any song, just return the first queue item.
    if (!playingNow) return this.queue[queueStartIndex];

    // Will be -1 if the user jumps from the playlist context to queue, and the song isn't in the queue.
    const queueIndex = this.queue.findIndex(track => track.videoId === playingNow.videoId);
    const pickIndex =
      queueIndex !== -1 ? (position === "next" ? queueIndex + 1 : queueIndex - 1) : 0;
    const pickedSong = this.queue[pickIndex];

    if (pop) {
      this.queue = this.queue.filter(music => music.videoId !== playingNow.videoId);
    }
    return pickedSong;
  }
}
