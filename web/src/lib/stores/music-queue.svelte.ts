import type { BaseMusicTrack } from "$lib/utils/validation/music-track";
import type { VideoType } from "$lib/utils/validation/playlist-track";

export interface QueueableMusic extends BaseMusicTrack {
  videoType: VideoType;
}

class MusicQueueStore {
  musicQueue = $state<QueueableMusic[]>([]);
  musicPlayingNow = $state<QueueableMusic | null>(null);
  isMusicQueueVisible = $state(false);

  playNext = (...tracks: QueueableMusic[]) => {
    const uniqueTracks = tracks.filter(
      newTrack => !this.musicQueue.some(queuedTrack => queuedTrack.videoId === newTrack.videoId),
    );

    this.musicQueue = [...uniqueTracks, ...this.musicQueue];
  };

  addToQueue = (...tracks: QueueableMusic[]) => {
    const uniqueTracks = tracks.filter(
      newTrack => !this.musicQueue.some(queuedTrack => queuedTrack.videoId === newTrack.videoId),
    );

    this.musicQueue = [...this.musicQueue, ...uniqueTracks];
  };
}

const musicQueueStore = new MusicQueueStore();

export default musicQueueStore;
