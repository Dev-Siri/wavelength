<script lang="ts">
  import { musicPlayer } from "$lib/stream-player/musicPlayer";

  import LyricsList from "../lyrics/LyricsList.svelte";
</script>

<div
  class="flex flex-col gap-10 pr-12 h-full scrollbar-hidden mb-[40vh] overflow-auto overflow-x-hidden lyrics-list"
>
  {#if musicPlayer.queue.playingNow}
    <LyricsList />
  {/if}
</div>

<style>
  .lyrics-list {
    -webkit-mask-image: linear-gradient(
      to bottom,
      transparent 0%,
      black 9%,
      black 40%,
      transparent 100%
    );
    mask-image: linear-gradient(to bottom, transparent 0%, black 12%, black 88%, transparent 100%);
  }
</style>
