<script lang="ts">
  import { EllipsisIcon, PlayIcon } from "@lucide/svelte";
  import { fly } from "svelte/transition";

  import type { MusicTrack } from "$lib/utils/validation/music-track";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { punctuatify } from "$lib/utils/format";

  import Image from "../Image.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import TrackLikeButton from "../track/TrackLikeButton.svelte";
  import { Button } from "../ui/button";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const { topResult }: { topResult: MusicTrack } = $props();

  let isHoveringCard = $state(false);

  function playSong() {
    const queueableTrack = { ...topResult, videoType: "VIDEO_TYPE_TRACK" } satisfies QueueableMusic;

    musicQueueStore.musicPlaylistContext = [];
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  class="relative w-full bg-muted bg-opacity-40 rounded-2xl h-full p-5 duration-200"
  tabindex={0}
  role="button"
  onclick={playSong}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
  onmouseenter={() => (isHoveringCard = true)}
  onmouseleave={() => (isHoveringCard = false)}
>
  <div class="flex absolute right-5">
    <TrackLikeButton music={topResult} />
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Button variant="ghost" size="sm">
          <EllipsisIcon class="text-gray-400" />
        </Button>
      </DropdownMenu.Trigger>
      <DropdownMenu.Content>
        <PlaylistToggleOptions music={topResult} toggle={{ type: "add" }} />
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  </div>
  <Image
    src={topResult.thumbnail}
    alt="Top Result Thumbnail"
    height={144}
    width={144}
    class="rounded-lg h-36 w-36"
  />
  <h2
    class="scroll-m-20 pb-2 text-3xl font-semibold tracking-tight leading-none transition-colors {topResult
      .title.length > 30
      ? 'mt-2'
      : 'mt-4'}"
  >
    {topResult.title.length > 65 ? `${topResult.title.slice(0, 65)}...` : topResult.title}
  </h2>
  <p class="text-muted-foreground text-md">
    {punctuatify(topResult.artists.map(artist => artist.title))}
  </p>
  {#if isHoveringCard}
    <div class="right-5 top-[70%] absolute">
      <div in:fly={{ y: 10, x: 0 }}>
        <Button class="rounded-full h-14 w-14">
          <PlayIcon class="text-primary-foreground" fill="black" />
        </Button>
      </div>
    </div>
  {/if}
</div>
