import { getStreamUrl, getThumbnailUrl } from "$lib/utils/url";
import { get, set } from "idb-keyval";
import musicQueueStore from "./music-queue.svelte";

type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPlayer = $state<HTMLAudioElement | null>(null);
  musicPreviewPlayer = $state<HTMLVideoElement | null>(null);

  isPlaying = $state(false);
  visiblePanel = $state<MusicInfoPanels | null>(null);
  repeatMode = $state<MusicRepeatMode>("none");
  isMuted = $state(false);
  source = $state<string | null>(null);
  currentTime = $state(0);
  duration = $state(0);
  volume = $state(1);

  loadTrack = async (videoId: string) => {
    if (!musicQueueStore.musicPlayingNow) return (navigator.mediaSession.metadata = null);

    musicPlayerStore.currentTime = 0;

    const cachedBufferKey = `cached_audio_buffer-${videoId}`;
    const cachedBuffer = await get(cachedBufferKey);

    let decodedUrl: string;

    if (cachedBuffer instanceof ArrayBuffer) {
      const cachedBlob = new Blob([cachedBuffer]);
      decodedUrl = URL.createObjectURL(cachedBlob);
    } else {
      const res = await fetch(getStreamUrl(videoId, "audio"));

      if (!res.ok) return;

      const arrayBuffer = await res.arrayBuffer();

      await set(cachedBufferKey, arrayBuffer);

      const cachedBlob = new Blob([arrayBuffer]);
      decodedUrl = URL.createObjectURL(cachedBlob);
    }

    musicPlayerStore.source = decodedUrl;

    navigator.mediaSession.metadata = new MediaMetadata({
      title: musicQueueStore.musicPlayingNow.title,
      artist: musicQueueStore.musicPlayingNow.author,
      artwork: [
        {
          src: getThumbnailUrl(videoId),
          sizes: "256x256",
          type: "image/jpeg",
        },
      ],
    });
  };

  seek = (time: number) => {
    if (!this.musicPlayer) return;

    this.musicPlayer.currentTime = time;
    this.currentTime = time;
  };

  playMusic = async () => {
    if (this.currentTime === this.duration) this.currentTime = 0;

    await this.musicPlayer?.play();
    this.isPlaying = true;
  };

  pauseMusic = () => {
    this.musicPlayer?.pause();
    this.isPlaying = false;
  };
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
