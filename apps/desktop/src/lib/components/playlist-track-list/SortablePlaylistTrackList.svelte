<script lang="ts">
  import { SortableList, sortItems } from "@rodrigodagostino/svelte-sortable-list";
  import { createMutation } from "@tanstack/svelte-query";
  import { z } from "zod";

  import type { Playlist, PlaylistTrack, PlaylistTrackLikedStatus } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/queue/MusicQueue";

  import { svelteMutationKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";

  import PlaylistTracksListItem from "./PlaylistTracksListItem.svelte";

  const {
    playlistTracks,
    isRearrangingList,
    playlist,
    likedStatus,
  }: {
    playlist: Playlist;
    playlistTracks: PlaylistTrack[];
    isRearrangingList: boolean;
    likedStatus: PlaylistTrackLikedStatus;
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

  const context = $derived({
    type: "playlist",
    playlistId: playlist.playlistId,
    sourceName: playlist.name,
    offlineTracks: playlistTracks,
  } satisfies MusicPlaylistContextSource);
</script>

{#if isRearrangingList}
  <SortableList.Root ondragend={handleSort}>
    {#each items as music, i (`${music.videoId}-${music.positionInPlaylist}`)}
      <SortableList.Item id={music.playlistTrackId} index={i}>
        <PlaylistTracksListItem
          isPreLiked={likedStatus[music.videoId] ?? false}
          {playlist}
          {music}
          {isRearrangingList}
          {context}
          index={i}
        />
      </SortableList.Item>
    {/each}
  </SortableList.Root>
{:else}
  {#each items as music, index (`${music.videoId}-${music.title}`)}
    <PlaylistTracksListItem
      isPreLiked={likedStatus[music.videoId] ?? false}
      {playlist}
      {music}
      {isRearrangingList}
      {context}
      {index}
    />
  {/each}
{/if}
