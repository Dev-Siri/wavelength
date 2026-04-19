<script lang="ts">
  import { PlayIcon } from "@lucide/svelte";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  import NowPlayingAnimation from "../NowPlayingAnimation.svelte";

  const {
    position,
    onClick,
    videoId,
  }: {
    position: number;
    onClick: () => void;
    videoId: string;
  } = $props();

  const isTrackPlaying = $derived(musicPlayer.queue.playingNow?.videoId === videoId);
</script>

<div
  class="flex flex-col items-center justify-center relative group"
  onclick={onClick}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && onClick()}
  role="button"
  tabindex="0"
>
  <span
    class="absolute left-1/3 self-center opacity-0 group-hover:opacity-100"
    class:opacity-100={isTrackPlaying && musicPlayer.isPlaying}
  >
    {#if isTrackPlaying && musicPlayer.isPlaying}
      <div class="inline">
        <NowPlayingAnimation height={5} width={15} />
      </div>
    {:else}
      <PlayIcon size={14} fill="white" />
    {/if}
  </span>
  <span
    class="text-sm text-muted-foreground font-bold px-4 group-hover:opacity-0"
    class:opacity-0={isTrackPlaying && musicPlayer.isPlaying}
  >
    {position}
  </span>
</div>
