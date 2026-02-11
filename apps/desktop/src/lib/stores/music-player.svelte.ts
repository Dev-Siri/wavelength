import type { StreamPlayer } from "$lib/stream-player/player";

import { localStorageKeys } from "$lib/constants/keys";

type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPlayer = $state<StreamPlayer | null>(null);
  musicPreviewPlayer = $state<StreamPlayer | null>(null);

  isPlaying = $state(false);
  visiblePanel = $state<MusicInfoPanels | null>(null);
  repeatMode = $state<MusicRepeatMode>("none");
  isShuffleModeOn = $state(false);
  isMuted = $state(false);
  volume = $state(1);
  duration = $state(0);
  currentTime = $state(0);
  progress = $derived.by(() => {
    if (!this.duration) return 0;

    return (this.currentTime / this.duration) * 100;
  });

  playMusic = async () => {
    if (!this.musicPlayer) return;

    if (this.progress === 100) this.progress = 0;

    await this.musicPlayer.play();

    this.isPlaying = true;
  };

  pauseMusic = async () => {
    if (!this.musicPlayer) return;

    await this.musicPlayer.pause();
    this.isPlaying = false;
  };

  setVolume = async (newVolume: number) => {
    await this.musicPlayer?.setVolume(newVolume);
    localStorage.setItem(localStorageKeys.volume, musicPlayerStore.volume.toString());
  };

  toggleMute = async () => {
    if (musicPlayerStore.isMuted) {
      await musicPlayerStore.musicPlayer?.mute();
      this.isMuted = true;
    } else {
      await musicPlayerStore.musicPlayer?.unMute();
      this.isMuted = false;
    }
  };
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
