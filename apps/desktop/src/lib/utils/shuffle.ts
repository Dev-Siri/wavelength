import type { QueueableMusic } from "$lib/stream-player/MusicQueue.svelte";

/** Fisher-Yates shuffle implementation. */
export function shuffle(tracks: QueueableMusic[]) {
  const tracksCopy = [...tracks];

  for (let i = tracksCopy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [tracksCopy[i], tracksCopy[j]] = [tracksCopy[j], tracksCopy[i]];
  }

  return tracksCopy;
}

/** Based on the length of tracks in the list, generates a random index from where shuffle starts. */
export function shuffleStartIndex(musicListSize: number) {
  if (musicListSize <= 0) return 0;
  return Math.floor(Math.random() * musicListSize);
}
