<script lang="ts">
  import { PlayIcon } from "@lucide/svelte";

  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import Image from "../Image.svelte";
  import NowPlayingAnimation from "../NowPlayingAnimation.svelte";

  const { videoId, thumbnail }: { videoId: string; thumbnail: string } = $props();

  const isTrackPlaying = $derived(musicQueueStore.musicPlayingNow?.videoId === videoId);
  const coverVisibility = $derived(isTrackPlaying ? "opacity-40" : "group-hover:opacity-40");
</script>

<div
  class="flex flex-col aspect-square items-center justify-center relative h-14 w-14 duration-200"
>
  {#if isTrackPlaying}
    <div class="absolute z-50">
      <NowPlayingAnimation />
    </div>
  {:else}
    <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
  {/if}
  {#key thumbnail}
    <Image
      src={thumbnail}
      alt="Thumbnail"
      class="rounded-xl aspect-square object-cover h-full w-full {coverVisibility}"
      height={64}
      width={70}
    />
  {/key}
</div>
