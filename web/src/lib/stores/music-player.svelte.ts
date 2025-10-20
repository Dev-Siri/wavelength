import { getStreamUrl, getThumbnailUrl } from "$lib/utils/url";
import { get, set } from "idb-keyval";
import musicQueueStore from "./music-queue.svelte";

type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPreviewPlayer = $state<HTMLVideoElement | null>(null);

  isPlaying = $state(false);
  visiblePanel = $state<MusicInfoPanels | null>(null);
  repeatMode = $state<MusicRepeatMode>("none");
  isMuted = $state(false);
  source = $state<string | null>(null);
  currentTime = $state(0);
  duration = $state(0);
  volume = $state(1);

  constructor(
    private audioCtx: AudioContext | null = null,
    private gainNode: GainNode | null = null,
    private bufferSource: AudioBufferSourceNode | null = null,
    private decodedBuffer: AudioBuffer | null = null,
    private startTime = 0,
    private pausedAt = 0,
  ) {
    this.audioCtx = new AudioContext();
    this.gainNode = this.audioCtx.createGain();

    this.gainNode.connect(this.audioCtx.destination);
  }

  [Symbol.dispose]() {
    if (!this.audioCtx) return;

    this.gainNode?.disconnect(this.audioCtx.destination);
    this.audioCtx = null;
    this.gainNode = null;
  }

  private updateTime = () => {
    if (!this.audioCtx || !this.isPlaying) return;

    const elapsed = this.audioCtx.currentTime - this.startTime;
    this.currentTime = Math.min(elapsed, this.duration);

    if (this.isPlaying) requestAnimationFrame(this.updateTime);
  };

  loadTrack = async (videoId: string) => {
    if (!this.audioCtx) return;

    if (this.bufferSource) {
      this.bufferSource.stop();
      this.bufferSource.disconnect();
      this.bufferSource = null;
    }

    this.isPlaying = false;
    this.pausedAt = 0;
    this.currentTime = 0;
    this.duration = 0;
    this.decodedBuffer = null;

    const cachedBufferKey = `cached_audio_buffer-${videoId}`;
    const cachedBuffer = await get(cachedBufferKey);

    if (cachedBuffer instanceof ArrayBuffer) {
      const decoded = await this.audioCtx.decodeAudioData(cachedBuffer);
      this.decodedBuffer = decoded;
      this.duration = decoded.duration;
      return;
    }

    const url = getStreamUrl(videoId, "audio");

    const res = await fetch(url);
    const arrayBuffer = await res.arrayBuffer();
    await set(cachedBufferKey, arrayBuffer);
    const decoded = await this.audioCtx.decodeAudioData(arrayBuffer);

    this.decodedBuffer = decoded;
    this.duration = decoded.duration;

    if (!musicQueueStore.musicPlayingNow) return (navigator.mediaSession.metadata = null);

    navigator.mediaSession.metadata = new MediaMetadata({
      title: musicQueueStore.musicPlayingNow.title,
      artist: musicQueueStore.musicPlayingNow.author,
      artwork: [
        {
          src: getThumbnailUrl(musicQueueStore.musicPlayingNow.videoId),
          sizes: "256x256",
          type: "image/jpeg",
        },
      ],
    });
  };

  handleBufferEnd = () => {
    if (this.repeatMode === "one") return this.playMusic();

    this.isPlaying = false;

    const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    const wasSongTheLastInQueue = musicQueueStore.musicQueue.length - 1 === songThatWasPlayedIndex;

    let nextIndex = 0;

    if (wasSongTheLastInQueue) {
      nextIndex = 0;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    if (this.repeatMode === "all" || !wasSongTheLastInQueue)
      musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
  };

  playMusic = async () => {
    if (!this.decodedBuffer || !this.audioCtx || !this.gainNode) return;

    await this.audioCtx.resume();

    if (this.isPlaying) return;

    const newSource = this.audioCtx.createBufferSource();
    newSource.buffer = this.decodedBuffer;
    newSource.connect(this.gainNode);

    this.bufferSource = newSource;

    const offset = Math.min(this.pausedAt, this.decodedBuffer.duration);

    this.startTime = this.audioCtx.currentTime - offset;

    newSource.start(0, offset);
    newSource.onended = () => {
      if (this.isPlaying) this.handleBufferEnd();
    };

    this.isPlaying = true;
    requestAnimationFrame(this.updateTime);
  };

  pauseMusic = () => {
    if (!this.bufferSource || !this.audioCtx || !this.isPlaying) return;

    this.pausedAt = this.audioCtx.currentTime - this.startTime;

    this.bufferSource.stop();
    this.bufferSource.disconnect();
    this.bufferSource = null;

    this.isPlaying = false;
  };

  seek = (newTime: number) => {
    if (!this.decodedBuffer || !this.audioCtx || !this.gainNode) return;

    newTime = Math.max(0, Math.min(newTime, this.decodedBuffer.duration));

    if (this.bufferSource) {
      this.bufferSource.stop();
      this.bufferSource.disconnect();
    }

    const newSource = this.audioCtx.createBufferSource();
    newSource.buffer = this.decodedBuffer;
    newSource.connect(this.gainNode);

    this.bufferSource = newSource;
    this.pausedAt = newTime;
    this.startTime = this.audioCtx.currentTime - newTime;

    newSource.start(0, newTime);
    newSource.onended = this.handleBufferEnd;

    this.isPlaying = true;
    requestAnimationFrame(this.updateTime);
  };

  setVolume = (value: number) => {
    if (!this.audioCtx || !this.gainNode) return;

    this.volume = value;
    this.gainNode.gain.value = this.isMuted ? 0 : value;
  };

  mute = () => {
    if (!this.audioCtx || !this.gainNode) return;

    this.isMuted = true;
    this.gainNode.gain.value = 0;
  };

  unmute = () => {
    if (!this.audioCtx || !this.gainNode) return;

    this.isMuted = false;
    this.gainNode.gain.value = this.volume;
  };
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
