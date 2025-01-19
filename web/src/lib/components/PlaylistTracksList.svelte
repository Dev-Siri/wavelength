<script lang="ts">
  import {
    SortableItem,
    SortableList,
    sortItems,
    type SortEventDetail,
  } from "@rodrigodagostino/svelte-sortable-list";
  import { fade } from "svelte/transition";

  import type { PlayListTrack } from "$lib/db/schema";

  import queryClient from "$lib/utils/query-client";
  import TrackItem from "./TrackItem.svelte";

  export let playlistId: string;
  export let playlistTracks: PlayListTrack[];

  let items = playlistTracks.sort(
    (track, nextTrack) => track.positionInPlaylist - nextTrack.positionInPlaylist,
  );

  async function handleSort(event: CustomEvent<SortEventDetail>) {
    const { prevItemIndex, nextItemIndex } = event.detail;
    items = sortItems(items, prevItemIndex, nextItemIndex);

    await queryClient(location.toString(), `/api/playlists/${playlistId}/tracks`, {
      method: "PUT",
      searchParams: {
        prevIndex: prevItemIndex,
        nextIndex: nextItemIndex,
        playlistTrackId: items[nextItemIndex].playlistTrackId,
      },
    });
  }
</script>

<SortableList on:sort={handleSort}>
  {#each items as music, i}
    <SortableItem id={music.playlistTrackId} index={i}>
      <div class="flex items-center gap-2">
        <p
          class="text-lg px-2 text-muted-foreground hover:bg-gray-900 duration-200 rounded-full h-7 w-7 text-center"
          in:fade
          out:fade
        >
          {i + 1}
        </p>
        <TrackItem {music} />
      </div>
    </SortableItem>
  {/each}
</SortableList>
