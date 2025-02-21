<script lang="ts">
  import {
    SortableItem,
    SortableList,
    sortItems,
    type SortEventDetail,
  } from "@rodrigodagostino/svelte-sortable-list";

  import type { PlayListTrack } from "$lib/db/schema";

  import queryClient from "$lib/utils/query-client";
  import PlaylistTracksListItem from "./PlaylistTracksListItem.svelte";

  export let playlistId: string;
  export let playlistTracks: PlayListTrack[];
  export let isRearrangingList: boolean;

  let items = playlistTracks.sort(
    (track, nextTrack) => track.positionInPlaylist - nextTrack.positionInPlaylist,
  );
  $: prevItems = structuredClone(items);

  function handleSort(event: CustomEvent<SortEventDetail>) {
    const { prevItemIndex, nextItemIndex } = event.detail;

    items = sortItems(items, prevItemIndex, nextItemIndex);
  }

  $: {
    async function rearrangeItems() {
      await queryClient(location.toString(), `/api/playlists/${playlistId}/tracks`, {
        method: "PUT",
        body: items.map((_, i) => ({
          playlistTrackId: prevItems[i].playlistTrackId,
          newPos: i + 1,
        })),
      });
    }

    if (!isRearrangingList) rearrangeItems();
  }
</script>

{#if isRearrangingList}
  <SortableList on:sort={handleSort}>
    {#each items as music, i}
      <SortableItem id={music.playlistTrackId} index={i}>
        <PlaylistTracksListItem {music} {isRearrangingList} {i} />
      </SortableItem>
    {/each}
  </SortableList>
{:else}
  {#each items as music, i}
    <PlaylistTracksListItem {music} {isRearrangingList} {i} />
  {/each}
{/if}
