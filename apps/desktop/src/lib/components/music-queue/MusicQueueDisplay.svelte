<script lang="ts">
  import { XIcon } from "@lucide/svelte";

  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import cn from "$lib/utils/cn";

  import Button from "../ui/button/button.svelte";
  import MusicQueueListItem from "./MusicQueueListItem.svelte";

  const { class: className, presentationOnly }: { class?: string; presentationOnly?: boolean } =
    $props();

  const nextTextWithSource = $derived.by(() => {
    const { playlistContextSource } = musicPlayer.queue;

    if (playlistContextSource.type === "none") return "Next";

    return playlistContextSource.sourceName
      ? `Next from: ${playlistContextSource.sourceName}`
      : "Next";
  });
</script>

<div class={cn("h-full w-full bg-[#111]", className)}>
  <header class="flex justify-between items-center px-4 pt-2">
    <p class="text-lg font-semibold select-none">Queue</p>
    {#if !presentationOnly}
      <Button
        size="icon"
        variant="ghost"
        onclick={() => (musicInterfaceStore.isMusicQueueVisible = false)}
      >
        <XIcon size={18} />
      </Button>
    {/if}
  </header>
  <div
    class="h-full w-full flex flex-col gap-2 px-4 overflow-auto mt-2 pb-[60%] {presentationOnly
      ? 'scrollbar-hidden'
      : ''}"
  >
    <ul class="w-full">
      {#each musicPlayer.queue.queue as musicQueueItem (musicQueueItem.videoId)}
        <li class="h-fit flex flex-col w-full">
          <MusicQueueListItem {musicQueueItem} dismissable />
        </li>
      {/each}
    </ul>
    {#if musicPlayer.queue.playingNow}
      <ul class="w-full">
        <p class="text-lg font-semibold select-none my-2">Now playing</p>
        <li class="h-fit flex flex-col w-full">
          <MusicQueueListItem musicQueueItem={musicPlayer.queue.playingNow} />
        </li>
      </ul>
    {/if}
    {#if musicPlayer.queue.nextTracks?.length}
      <ul class="w-full">
        <p class="text-lg font-semibold select-none mb-2">
          {nextTextWithSource}
        </p>
        {#each musicPlayer.queue.nextTracks as musicQueueItem (musicQueueItem.videoId)}
          <li class="h-fit flex flex-col w-full">
            <MusicQueueListItem {musicQueueItem} />
          </li>
        {/each}
      </ul>
    {/if}
    {#if musicPlayer.queue.automixedTracks?.length}
      <ul class="w-full">
        <p class="text-lg font-semibold select-none mb-2">Up next</p>
        {#each musicPlayer.queue.automixedTracks as musicQueueItem (musicQueueItem.videoId)}
          <li class="h-fit flex flex-col w-full">
            <MusicQueueListItem {musicQueueItem} />
          </li>
        {/each}
      </ul>
    {/if}
  </div>
</div>
