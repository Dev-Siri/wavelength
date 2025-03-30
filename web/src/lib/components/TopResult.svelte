<script lang="ts">
  import { Play } from "lucide-svelte";
  import { fly } from "svelte/transition";

  import type { MusicTrack } from "$lib/server/api/interface/types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";

  import Image from "./Image.svelte";
  import { Button } from "./ui/button";

  const { topResult }: { topResult: MusicTrack } = $props();

  let isHoveringCard = $state(false);

  function playSong() {
    const queueableTrack = { ...topResult, videoType: "track" } satisfies QueueableMusic;

    musicQueueStore.addToQueue(queueableTrack);
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  class="relative w-full bg-muted bg-opacity-40 rounded-2xl h-fit p-5 hover:bg-muted duration-200"
  tabindex={0}
  role="button"
  onclick={playSong}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
  onmouseenter={() => (isHoveringCard = true)}
  onmouseleave={() => (isHoveringCard = false)}
>
  <Image
    src={topResult.thumbnail}
    alt="Top Result Thumbnail"
    height={112}
    width={112}
    class="rounded-lg h-28 w-28"
  />
  <h2
    class="scroll-m-20 pb-2 mt-4 text-3xl font-semibold tracking-tight leading-none transition-colors first:mt-0"
  >
    {topResult.title}
  </h2>
  <p class="text-muted-foreground text-md">{topResult.author}</p>
  {#if isHoveringCard}
    <div class="right-5 top-[70%] absolute">
      <div in:fly={{ y: 10, x: 0 }}>
        <Button class="rounded-full h-14 w-14">
          <Play class="text-primary-foreground" fill="black" />
        </Button>
      </div>
    </div>
  {/if}
</div>
