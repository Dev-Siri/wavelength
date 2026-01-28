import type { StreamPlayer } from "$lib/stream-player/player";

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
  progress = $state(0);

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
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
