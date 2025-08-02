<script lang="ts">
  import { ChevronDownIcon, Rows4Icon, XIcon } from "@lucide/svelte";
  import { slide } from "svelte/transition";

  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import MusicQueueListItem from "./MusicQueueListItem.svelte";
  import Button from "./ui/button/button.svelte";

  const currentIndex = $derived(
    musicQueueStore.musicPlayingNow
      ? musicQueueStore.musicQueue.indexOf(musicQueueStore.musicPlayingNow)
      : -1,
  );
  const nextIndex = $derived(currentIndex + 1);
  const upNextItem = $derived(
    musicQueueStore.musicQueue[nextIndex === musicQueueStore.musicQueue.length ? 0 : nextIndex] ||
      null,
  );
</script>

<div class="h-full w-full bg-black">
  {#if musicQueueStore.musicQueue.length}
    <div class="h-full w-full flex flex-col gap-2 p-4">
      <header class="flex justify-between items-center border-b border-b-border pb-2">
        <p class="text-sm select-none">Music Queue</p>
        <Button
          class="rounded-full p-0.5 px-3"
          variant="ghost"
          onclick={() => (musicQueueStore.isMusicQueueVisible = false)}
        >
          <XIcon size={3} />
        </Button>
      </header>
      <ul class="h-full w-full border-b border-b-border overflow-auto">
        {#each musicQueueStore.musicQueue as musicQueueItem, i}
          <li class="h-fit flex flex-col items-center w-full">
            <MusicQueueListItem {musicQueueItem} />
            {#if i !== musicQueueStore.musicQueue.length - 1}
              <span class="my-0.5">
                <ChevronDownIcon class="text-gray-500/80" size={20} />
              </span>
            {/if}
          </li>
        {/each}
      </ul>
      <div class="flex flex-col">
        <p class="mb-2">Up Next</p>
        {#key upNextItem}
          <div in:slide={{ duration: 200 }} out:slide={{ duration: 200 }}>
            <MusicQueueListItem musicQueueItem={upNextItem} />
          </div>
        {/key}
      </div>
    </div>
  {:else}
    <div class="flex flex-col gap-2 items-center justify-center h-full">
      <Rows4Icon size={44} class="text-gray-400" />
      <p class="text-sm text-gray-400 select-none">Music Queue is Empty.</p>
    </div>
  {/if}
</div>
