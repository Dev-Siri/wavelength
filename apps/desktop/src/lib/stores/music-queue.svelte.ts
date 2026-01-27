import type { MusicTrack } from "$lib/utils/validation/music-track";
import type { VideoType } from "$lib/utils/validation/playlist-track";

export interface QueueableMusic extends Omit<MusicTrack, "duration" | "isExplicit"> {
  videoType: VideoType;
}

class MusicQueueStore {
  musicPlayingNow = $state<QueueableMusic | null>(null);
  // Main playlist context used by all.
  musicPlaylistContext = $state<QueueableMusic[]>([]);
  // Stores a copy of the original playlist context when shuffle mode is enabled.
  musicPlaylistContextPreshuffle = $state<QueueableMusic[]>([]);
  isMusicQueueVisible = $state(false);
}

const musicQueueStore = new MusicQueueStore();

export default musicQueueStore;
