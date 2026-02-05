<script lang="ts">
  import { XIcon } from "@lucide/svelte";
  import { slide } from "svelte/transition";

  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import Button from "../ui/button/button.svelte";
  import MusicQueueListItem from "./MusicQueueListItem.svelte";

  const currentIndex = $derived(
    musicQueueStore.musicPlayingNow
      ? musicQueueStore.musicPlaylistContext.indexOf(musicQueueStore.musicPlayingNow) + 1
      : -1,
  );
  const nextIndex = $derived(currentIndex + 1);
  const upNextItem = $derived(
    musicQueueStore.musicPlaylistContext[
      nextIndex === musicQueueStore.musicPlaylistContext.length ? 0 : nextIndex
    ] || null,
  );
</script>

<div class="h-full w-full bg-[#111] rounded-xl">
  <header class="flex justify-between items-center px-4 pt-2">
    <p class="text-xl font-semibold select-none">Queue</p>
    <Button
      class="px-3"
      variant="ghost"
      onclick={() => (musicQueueStore.isMusicQueueVisible = false)}
    >
      <XIcon size={18} />
    </Button>
  </header>
  {#if musicQueueStore.musicPlaylistContext.length}
    <div class="h-full w-full flex flex-col gap-2 px-4 overflow-auto">
      <ul class="w-full overflow-auto">
        {#each musicQueueStore.musicPlaylistContext as musicQueueItem, i}
          <li class="h-fit flex flex-col items-center w-full mb-1">
            <MusicQueueListItem {musicQueueItem} />
          </li>
        {/each}
      </ul>
      <div class="flex flex-col">
        <p class="text-xl font-semibold mb-2 select-none">Next</p>
        {#key upNextItem}
          <div in:slide={{ duration: 200 }} out:slide={{ duration: 200 }}>
            <MusicQueueListItem musicQueueItem={upNextItem} />
          </div>
        {/key}
      </div>
    </div>
  {/if}
</div>
