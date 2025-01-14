import { get, writable } from "svelte/store";

import type { YouTubePlayer } from "youtube-player/dist/types";

type MusicInfoPanels = "playingNow" | "lyrics";
type MusicRepeatMode = "none" | "all" | "one";

export const musicPlayer = writable<YouTubePlayer | null>(null);
export const musicPreviewPlayer = writable<YouTubePlayer | null>(null);
export const isMusicPlaying = writable(false);
export const musicPlayerProgress = writable(0);
export const visiblePanel = writable<MusicInfoPanels | null>(null);
export const musicRepeatMode = writable<MusicRepeatMode>("none");
export const isMusicMuted = writable(false);

export async function playMusic() {
  const player = get(musicPlayer);
  const progress = get(musicPlayerProgress);

  if (!player) return;

  if (progress === 100) musicPlayerProgress.set(0);

  await player.playVideo();

  isMusicPlaying.set(true);
}

export async function pauseMusic() {
  const player = get(musicPlayer);

  if (!player) return;

  await player.pauseVideo();
  isMusicPlaying.set(false);
}
