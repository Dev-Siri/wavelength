<script lang="ts">
  import { XIcon } from "@lucide/svelte";
  import { toast } from "svelte-sonner";
  import { fly } from "svelte/transition";

  import type { QueueableMusic } from "$lib/stream-player/queue/MusicQueue";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { reportErrorToBackend } from "$lib/utils/query-client";

  import ArtistLink from "../artist/ArtistLink.svelte";
  import TrackCover from "../track/TrackCover.svelte";

  const { musicQueueItem, dismissable }: { musicQueueItem: QueueableMusic; dismissable?: boolean } =
    $props();

  function removeMusicFromQueue(
    e: (MouseEvent | KeyboardEvent) & { currentTarget: EventTarget & HTMLDivElement },
  ) {
    e.stopPropagation();
    musicPlayer.queue.removeFromQueue(musicQueueItem.videoId);
  }

  async function playSong() {
    try {
      await musicPlayer.load(musicQueueItem);
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "MusicQueueListItem: playSong()",
      });
    }
  }
</script>

<button
  type="button"
  class="flex p-1.5 w-full items-center rounded-2xl duration-200 cursor-pointer hover:bg-border/70"
  onclick={playSong}
  in:fly={{ duration: 200, y: -30 }}
  out:fly={{ duration: 300, y: -30 }}
>
  <TrackCover {...musicQueueItem} />
  <div class="flex flex-col items-start ml-2 justify-center text-start">
    <p class="text-sm line-clamp-1 text-ellipsis font-semibold">
      {musicQueueItem.title}
    </p>
    <div class="flex">
      {#each musicQueueItem.artists as artist, i (`music-queue-item-${artist.browseId}-${artist.title}-${i}`)}
        <ArtistLink
          {...artist}
          isUVideo={musicQueueItem.videoType === "VIDEO_TYPE_UVIDEO"}
          trailingComma={i + 1 !== musicQueueItem.artists.length}
        />
      {/each}
    </div>
  </div>
  {#if dismissable}
    <div
      role="button"
      class="ml-auto mr-2"
      tabindex="0"
      onclick={removeMusicFromQueue}
      onkeydown={removeMusicFromQueue}
    >
      <XIcon size={15} />
    </div>
  {/if}
</button>
