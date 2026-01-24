import type { QueueableMusic } from "$lib/stores/music-queue.svelte";

/** Fisher-Yates shuffle implementation. */
export function shuffle(tracks: QueueableMusic[]) {
  for (let i = tracks.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [tracks[i], tracks[j]] = [tracks[j], tracks[i]];
  }

  return tracks;
}
