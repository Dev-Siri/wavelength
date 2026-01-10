<script lang="ts">
  import { ListMinusIcon } from "@lucide/svelte";
  import { fly } from "svelte/transition";

  import type { QueueableMusic } from "$lib/stores/music-queue.svelte";

  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { punctuatify } from "$lib/utils/format";

  import Image from "./Image.svelte";

  const { musicQueueItem }: { musicQueueItem: QueueableMusic } = $props();

  function removeMusicFromQueue(
    event: (MouseEvent | KeyboardEvent) & { currentTarget: EventTarget & HTMLDivElement },
  ) {
    event.stopPropagation();
    musicQueueStore.musicQueue = musicQueueStore.musicQueue.filter(
      item => item.videoId !== musicQueueItem.videoId,
    );
  }
</script>

<button
  type="button"
  class="flex bg-border/60 p-1 w-full items-center rounded-2xl duration-200 cursor-pointer hover:bg-border/70"
  onclick={() => (musicQueueStore.musicPlayingNow = musicQueueItem)}
  in:fly={{ duration: 200, y: -30 }}
  out:fly={{ duration: 300, y: -30 }}
>
  <Image
    src={musicQueueItem.thumbnail}
    alt="{musicQueueItem.title}'s Thumbnail"
    height={40}
    width={40}
    class="rounded-xl"
  />
  <div class="flex flex-col items-start ml-2 justify-center">
    <p class="text-xs">
      {musicQueueItem.title.length > 20
        ? `${musicQueueItem.title.slice(0, 20)}...`
        : musicQueueItem.title}
    </p>
    <p class="text-[9px] text-gray-400/90">
      {punctuatify(musicQueueStore.musicPlayingNow?.artists.map(artist => artist.title) ?? [])}
    </p>
  </div>
  <div
    role="button"
    class="ml-auto mr-2"
    tabindex="0"
    onclick={removeMusicFromQueue}
    onkeydown={removeMusicFromQueue}
  >
    <ListMinusIcon size={15} color="red" />
  </div>
</button>
