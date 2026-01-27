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

    musicQueueStore.musicPlayingNow = queueableTrack;
    musicQueueStore.musicPlaylistContext = [];
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  class="h-48 flex flex-col py-2 mb-[20%] items-center cursor-pointer group"
  tabindex={0}
  role="button"
  onclick={playSong}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
  onmouseenter={() => (isHoveringCard = true)}
  onmouseleave={() => (isHoveringCard = false)}
>
  <div class="flex items-center justify-center h-48 w-48 p-2 relative aspect-square rounded-2xl">
    <div class="h-full w-full aspect-square rounded-2xl relative inline-block">
      {#key quickPick.thumbnail}
        <Image
          src={quickPick.thumbnail}
          alt="Thumbnail"
          height={192}
          width={192}
          class="object-cover aspect-square group-hover:opacity-60 duration-200 shadow-black h-full w-full rounded-xl"
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
  <Tooltip.Root>
    <Tooltip.Trigger>
      <p class="text-ellipsis w-full text-secondary-foreground text-xs">
        {quickPick.title.length > 25 ? `${quickPick.title.slice(0, 25)}...` : quickPick.title}
      </p>
      <p class=" text-muted-foreground text-xs">
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
</div>
