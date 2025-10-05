<script lang="ts">
  import {
    SortableItem,
    SortableList,
    sortItems,
    type SortEventDetail,
  } from "@rodrigodagostino/svelte-sortable-list";
  import { createMutation } from "@tanstack/svelte-query";
  import { z } from "zod";

  import type { PlaylistTrack } from "$lib/utils/validation/playlist-track";

  import { svelteMutationKeys } from "$lib/constants/keys";
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

  const rearrangeItemsMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.rearrangePlaylistTracks(playlistId),
    mutationFn: () =>
      backendClient(`/playlists/playlist/${playlistId}/tracks`, z.string(), {
        method: "PUT",
        body: items.map((_, i) => ({
          playlistTrackId: prevItems[i].playlistTrackId,
          newPos: i + 1,
        })),
      }),
  }));

  function handleSort(event: CustomEvent<SortEventDetail>) {
    const { prevItemIndex, nextItemIndex } = event.detail;

    items = sortItems(items, prevItemIndex, nextItemIndex);
    rearrangeItemsMutation.mutate();
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
