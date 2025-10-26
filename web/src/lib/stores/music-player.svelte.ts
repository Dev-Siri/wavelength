type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPlayer = $state<HTMLAudioElement | null>(null);
  musicPreviewPlayer = $state<HTMLVideoElement | null>(null);

  isPlaying = $state(false);
  visiblePanel = $state<MusicInfoPanels | null>(null);
  repeatMode = $state<MusicRepeatMode>("none");
  isMuted = $state(false);
  currentTime = $state(0);
  duration = $state(0);
  volume = $state(1);

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
