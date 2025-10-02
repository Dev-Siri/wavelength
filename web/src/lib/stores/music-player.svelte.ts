type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPlayer = $state<HTMLAudioElement | null>(null);
  musicPreviewPlayer = $state<HTMLVideoElement | null>(null);
  isMusicPlaying = $state(false);
  visiblePanel = $state<MusicInfoPanels | null>(null);
  musicRepeatMode = $state<MusicRepeatMode>("none");
  isMusicMuted = $state(false);
  musicSource = $state<string | null>(null);
  musicCurrentTime = $state(0);
  musicDuration = $state(0);
  volume = $state(1);

  playMusic = async () => {
    if (this.musicCurrentTime === this.musicDuration) this.musicCurrentTime = 0;

    await this.musicPlayer?.play();
    this.isMusicPlaying = true;
  };

  pauseMusic = () => {
    this.musicPlayer?.pause();
    this.isMusicPlaying = false;
  };
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
