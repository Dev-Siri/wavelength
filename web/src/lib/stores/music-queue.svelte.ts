import type { VideoTypeEnum } from "$lib/db/schema";
import type { BaseMusicTrack } from "$lib/server/api/interface/types";

export interface QueueableMusic extends BaseMusicTrack {
  videoType: VideoTypeEnum;
}

class MusicQueueStore {
  musicQueue = $state<QueueableMusic[]>([]);
  musicPlayingNow = $state<QueueableMusic | null>(null);
  isMusicQueueVisible = $state(false);

  playNext = (...tracks: QueueableMusic[]) => {
    this.musicQueue = [...tracks, ...this.musicQueue];
  };

  addToQueue = (...tracks: QueueableMusic[]) => {
    this.musicQueue = [...this.musicQueue, ...tracks];
  };
}

const musicQueueStore = new MusicQueueStore();

export default musicQueueStore;
