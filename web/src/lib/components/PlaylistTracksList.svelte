<script lang="ts">
  import { SortableList, sortItems } from "@rodrigodagostino/svelte-sortable-list";
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

  function handleSort({
    draggedItemIndex,
    targetItemIndex,
    isCanceled,
  }: SortableList.RootEvents["ondragend"]) {
    if (!isCanceled && typeof targetItemIndex === "number" && draggedItemIndex !== targetItemIndex)
      items = sortItems(items, draggedItemIndex, targetItemIndex);

    rearrangeItemsMutation.mutate();
  }
</script>

{#if isRearrangingList}
  <SortableList.Root ondragend={handleSort}>
    {#each items as music, i (`${music.playlistId}-${i}`)}
      {console.log(`${i}: `, music.playlistTrackId)}
      <SortableList.Item id={music.playlistTrackId} index={i}>
        <PlaylistTracksListItem {music} {isRearrangingList} {i} />
      </SortableList.Item>
    {/each}
  </SortableList.Root>
{:else}
  {#each items as music, i}
    <PlaylistTracksListItem {music} {isRearrangingList} {i} />
  {/each}
{/if}
