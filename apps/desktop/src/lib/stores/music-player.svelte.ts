import type { YouTubePlayer } from "youtube-player/dist/types.js";

type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPlayer = $state<YouTubePlayer | null>(null);
  musicPreviewPlayer = $state<YouTubePlayer | null>(null);

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

    await this.musicPlayer.playVideo();

    this.isPlaying = true;
  };

  pauseMusic = async () => {
    if (!this.musicPlayer) return;

    await this.musicPlayer.pauseVideo();
    this.isPlaying = false;
  };
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
