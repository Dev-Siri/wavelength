import { writable } from "svelte/store";

import type { VideoTypeEnum } from "$lib/db/schema";
import type { BaseMusicTrack } from "$lib/server/api/interface/types";

export interface QueueableMusic extends BaseMusicTrack {
  videoType: VideoTypeEnum;
}

export const musicQueue = writable<QueueableMusic[]>([]);
export const musicPlayingNow = writable<QueueableMusic | null>(null);

export function playNext(...tracks: QueueableMusic[]) {
  musicQueue.update(prevMusicQueue => [...tracks, ...prevMusicQueue]);
}

export function addToQueue(...tracks: QueueableMusic[]) {
  musicQueue.update(prevMusicQueue => [...prevMusicQueue, ...tracks]);
}
