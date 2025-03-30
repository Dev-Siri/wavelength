import type { YouTubePlayer } from "youtube-player/dist/types";

type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

class MusicPlayerStore {
  musicPlayer = $state<YouTubePlayer | null>(null);
  musicPreviewPlayer = $state<YouTubePlayer | null>(null);
  isMusicPlaying = $state(false);
  musicPlayerProgress = $state(0);
  visiblePanel = $state<MusicInfoPanels | null>(null);
  musicRepeatMode = $state<MusicRepeatMode>("none");
  isMusicMuted = $state(false);

  playMusic = async () => {
    if (!this.musicPlayer) return;

    if (this.musicPlayerProgress === 100) this.musicPlayerProgress = 0;

    await this.musicPlayer.playVideo();

    this.isMusicPlaying = true;
  };

  pauseMusic = async () => {
    if (!this.musicPlayer) return;

    await this.musicPlayer.pauseVideo();
    this.isMusicPlaying = false;
  };
}

const musicPlayerStore = new MusicPlayerStore();

export default musicPlayerStore;
