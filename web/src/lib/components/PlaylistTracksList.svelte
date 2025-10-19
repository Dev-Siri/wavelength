<script lang="ts">
  import { SortableList, sortItems } from "@rodrigodagostino/svelte-sortable-list";
  import { createMutation } from "@tanstack/svelte-query";
  import { z } from "zod";

  import type { PlaylistTrack } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";

  import PlaylistTracksListItem from "./PlaylistTracksListItem.svelte";

  const {
    playlistTracks,
    isRearrangingList,
    playlist,
  }: {
    playlist: Playlist;
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
    mutationKey: svelteMutationKeys.rearrangePlaylistTracks(playlist.playlistId),
    mutationFn: () =>
      backendClient(`/playlists/playlist/${playlist.playlistId}/tracks`, z.string(), {
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
      <SortableList.Item id={music.playlistTrackId} index={i}>
        <PlaylistTracksListItem {playlist} {music} {isRearrangingList} />
      </SortableList.Item>
    {/each}
  </SortableList.Root>
{:else}
  {#each items as music}
    <PlaylistTracksListItem {playlist} {music} {isRearrangingList} />
  {/each}
{/if}
