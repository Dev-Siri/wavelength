<script lang="ts">
  import { PlayIcon } from "@lucide/svelte";
  import { fade } from "svelte/transition";

  import type { EmbeddedAlbum } from "$lib/utils/validation/albums";
  import type { QuickPick } from "$lib/utils/validation/quick-picks-response";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";

  import Button from "$lib/components/ui/button/button.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import Image from "./Image.svelte";

  const { quickPick }: { quickPick: QuickPick } = $props();

  let isHoveringCard = $state(false);

  function playSong() {
    const queueableTrack = {
      ...quickPick,
      // Brilliant TypeScript.
      album: quickPick.album as EmbeddedAlbum | undefined,
      videoType: "VIDEO_TYPE_TRACK",
    } satisfies QueueableMusic;

    musicQueueStore.addToQueue(queueableTrack);
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  class="h-24 flex py-2 items-center duration-200 bg-[#1c1c1c] hover:bg-muted rounded-2xl cursor-pointer group"
  tabindex={0}
  role="button"
  onclick={playSong}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
  onmouseenter={() => (isHoveringCard = true)}
  onmouseleave={() => (isHoveringCard = false)}
>
  <div class="flex items-center justify-center h-24 w-24 p-2 relative aspect-square rounded-2xl">
    <div class="h-full w-full aspect-square rounded-2xl relative inline-block">
      {#key quickPick.thumbnail}
        <Image
          src={quickPick.thumbnail}
          alt="Thumbnail"
          height={192}
          width={192}
          class="object-cover aspect-square shadow-black h-full w-full rounded-2xl"
        />
      {/key}
    </div>
    {#if isHoveringCard}
      <div class="absolute" in:fade={{ duration: 200 }}>
        <Button class="rounded-full h-8 w-7">
          <PlayIcon class="text-primary-foreground" fill="black" />
        </Button>
      </div>
    {/if}
  </div>
  {#if quickPick.title}
    <Tooltip.Root>
      <Tooltip.Trigger>
        <p class="text-ellipsis w-full text-start text-secondary-foreground text-base">
          {quickPick.title.length > 30 ? `${quickPick.title.slice(0, 27)}...` : quickPick.title}
        </p>
        <p class="text-start text-muted-foreground text-sm">
          {#each quickPick.artists as artist, i}
            <span>
              {artist.title}{quickPick.artists[i + 1] ? ", " : ""}
            </span>
          {/each}
        </p>
      </Tooltip.Trigger>
      <Tooltip.Content>
        <p>{quickPick.title}</p>
      </Tooltip.Content>
    </Tooltip.Root>
  {/if}
</div>
