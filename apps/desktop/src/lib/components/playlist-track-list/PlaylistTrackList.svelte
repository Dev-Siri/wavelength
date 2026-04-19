<script lang="ts">
  import { ClockIcon, HashIcon, ListPlusIcon } from "@lucide/svelte";

  import type { Playlist, PlaylistTrack, PlaylistTrackLikedStatus } from "$lib/schemas/playlist";

  import Button from "$lib/components/ui/button/button.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import SortablePlaylistTrackList from "./SortablePlaylistTrackList.svelte";

  const {
    playlist,
    playlistTracks,
    likedStatus,
  }: {
    playlist: Playlist;
    playlistTracks: PlaylistTrack[];
    likedStatus: PlaylistTrackLikedStatus;
  } = $props();

  let isRearrangingList = $state(false);
</script>

<div class="h-fit" id="playlist-track-list">
  {#if playlistTracks.length}
    <header class="flex items-center select-none text-muted-foreground">
      <section class="flex items-center gap-10 w-1/3">
        <Tooltip.Root>
          <Tooltip.Trigger
            class="cursor-pointer p-1.5 pl-4.5 rounded-full duration-200"
            onclick={() => (isRearrangingList = !isRearrangingList)}
          >
            <HashIcon size={14} />
          </Tooltip.Trigger>
          <Tooltip.Content>
            <p>
              {isRearrangingList ? "Stop" : "Enable"} Rearranging Tracks
            </p>
          </Tooltip.Content>
        </Tooltip.Root>
        <p class="text-sm">Title</p>
      </section>
      <section class="flex justify-center w-1/3">
        <p class="text-sm">Album</p>
      </section>
      <section class="flex justify-center w-1/3">
        <ClockIcon size={14} class="mr-6" />
      </section>
    </header>
    <div class="bg-secondary h-[1px] w-full my-2.5 rounded-full"></div>
    <div class="mt-2 overflow-x-hidden">
      {#key playlistTracks.length}
        <SortablePlaylistTrackList {likedStatus} {playlistTracks} {playlist} {isRearrangingList} />
      {/key}
    </div>
  {:else}
    <div class="mt-10 flex gap-2 flex-col items-center justify-center">
      <ListPlusIcon size={40} />
      <h4 class="text-center text-2xl">Your playlist is empty</h4>
      <Button variant="secondary" onclick={() => document.getElementById("search-input")?.focus()}>
        Discover new music
      </Button>
    </div>
  {/if}
</div>
