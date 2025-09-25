<script lang="ts">
  import {
    SortableItem,
    SortableList,
    sortItems,
    type SortEventDetail,
  } from "@rodrigodagostino/svelte-sortable-list";

  import type { PlaylistTrack } from "$lib/types.js";

  import { backendClient } from "$lib/utils/query-client.js";

  import PlaylistTracksListItem from "./PlaylistTracksListItem.svelte";

  const {
    playlistId,
    playlistTracks,
    isRearrangingList,
  }: {
    playlistId: string;
    playlistTracks: PlaylistTrack[];
    isRearrangingList: boolean;
  } = $props();

  let items = $state(
    playlistTracks.toSorted(
      (track, nextTrack) => track.positionInPlaylist - nextTrack.positionInPlaylist,
    ),
  );
  let prevItems = $derived([...items]);

  function handleSort(event: CustomEvent<SortEventDetail>) {
    const { prevItemIndex, nextItemIndex } = event.detail;

    items = sortItems(items, prevItemIndex, nextItemIndex);
  }

  $effect(() => {
    async function rearrangeItems() {
      await backendClient(`/playlists/playlist/${playlistId}/tracks`, {
        method: "PUT",
        body: items.map((_, i) => ({
          playlistTrackId: prevItems[i].playlistTrackId,
          newPos: i + 1,
        })),
      });
    }

    if (!isRearrangingList) rearrangeItems();
  });
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
