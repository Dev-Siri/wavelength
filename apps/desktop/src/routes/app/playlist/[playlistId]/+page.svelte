<script lang="ts">
  import { page } from "$app/state";
  import { MusicIcon } from "@lucide/svelte";
  import { isTauri } from "@tauri-apps/api/core";
  import { fly } from "svelte/transition";

  import type { MusicPlaylistContextSource } from "$lib/stream-player/MusicQueue.svelte";

  import usePlaylistQuery from "$lib/queries/playlist.svelte";
  import usePlaylistPlaylengthQuery from "$lib/queries/playlistPlaylength";
  import usePlaylistTracksQuery from "$lib/queries/playlistTracks";
  import usePlaylistTracksLikedStatusQuery from "$lib/queries/playlistTracksLikedStatus";
  import connectivityStore from "$lib/stores/connectivity.svelte";
  import userStore from "$lib/stores/user.svelte.js";

  import ChangePlaylistVisibilityButton from "$lib/components/action-buttons/ChangePlaylistVisibilityButton.svelte";
  import DownloadButton from "$lib/components/action-buttons/DownloadButton.svelte";
  import AutoPlaylistCover from "$lib/components/AutoPlaylistCover.svelte";
  import EditPlaylistDetailsDialog from "$lib/components/EditPlaylistDetailsDialog.svelte";
  import Image from "$lib/components/Image.svelte";
  import PlaylistTrackList from "$lib/components/playlist-track-list/PlaylistTrackList.svelte";
  import PlaylistLength from "$lib/components/playlist/PlaylistLength.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import PlaylistThemeGradient from "$lib/components/playlist/PlaylistThemeGradient.svelte";
  import PlaylistTrackListSkeleton from "$lib/components/skeletons/PlaylistTrackListSkeleton.svelte";
  import * as Dialog from "$lib/components/ui/dialog";
  import Spinner from "$lib/components/ui/spinner/spinner.svelte";
  import RecommendedSongs from "./recommended-songs.svelte";

  let pageTitle = $state("Playlist");

  const playlistQuery = $derived(usePlaylistQuery(page.params.playlistId ?? ""));
  const playlistTracksQuery = $derived(usePlaylistTracksQuery(page.params.playlistId ?? ""));
  const playlistTracksLikedStatus = $derived(
    usePlaylistTracksLikedStatusQuery(page.params.playlistId ?? ""),
  );
  const playlistPlaylengthQuery = $derived(
    usePlaylistPlaylengthQuery(page.params.playlistId ?? ""),
  );
  const playlistCover = $derived(playlistQuery.data?.playlist.coverImage ?? "");

  const playlistTracks = $derived.by(() => {
    if (!playlistTracksQuery.data?.playlistTracks) return [];

    const { playlistTracks } = playlistTracksQuery.data;
    return playlistTracks.toSorted((a, b) => a.positionInPlaylist - b.positionInPlaylist);
  });

  $effect(() => {
    if (playlistQuery.isSuccess) pageTitle = `${playlistQuery.data.playlist.name}`;
  });

  const context = $derived.by(() => {
    if (!playlistQuery.data?.playlist) return;

    const { name, playlistId } = playlistQuery.data.playlist;
    return {
      type: "playlist",
      playlistId,
      sourceName: name,
      offlineTracks: playlistTracks,
    } satisfies MusicPlaylistContextSource;
  });

  const likedStatus = $derived(playlistTracksLikedStatus.data?.likedTracks ?? {});
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<Dialog.Root>
  <div
    class="flex flex-col h-full w-full bg-secondary/30 rounded-2xl overflow-y-auto"
    in:fly={{ y: 20, duration: 250 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    {#if playlistQuery.isLoading}
      <div class="h-3/4 w-full flex items-center justify-center">
        <Spinner class="size-28" />
      </div>
    {:else if playlistQuery.isSuccess}
      {@const { playlist } = playlistQuery.data}
      <EditPlaylistDetailsDialog initialPlaylist={playlist} />
      <div class="relative w-full p-4 h-fit pb-[20%] rounded-2xl">
        <PlaylistThemeGradient {playlistCover} />
        <div class="relative flex gap-4">
          {#if playlist.coverImage}
            {#key playlist}
              <Image
                src={playlist.coverImage}
                alt="Playlist Cover"
                class="h-60 w-60 rounded-sm aspect-square"
                height={240}
                width={240}
              />
            {/key}
          {:else if playlistTracks.length}
            <AutoPlaylistCover
              thumbnails={playlistTracks.slice(0, 4).map(({ thumbnail }) => thumbnail)}
            />
          {:else}
            <div class="h-56 w-56 grid place-items-center rounded-sm aspect-square bg-muted">
              <MusicIcon class="text-gray-300" size={60} />
            </div>
          {/if}
          <div class="flex flex-col justify-center w-3/5 h-52 gap-2">
            <span class="text-sm ml-0.5 select-none">Playlist</span>
            {#if userStore.user?.email === playlist.authorGoogleEmail}
              <Dialog.Trigger class="text-start cursor-pointer">
                <h1 class="text-6xl lg:text-7xl font-semibold text-balance">{playlist.name}</h1>
              </Dialog.Trigger>
            {:else}
              <h1 class="text-6xl lg:text-7xl font-semibold text-balance">{playlist.name}</h1>
            {/if}
            <div class="flex gap-2 items-center">
              {#key playlist.authorImage}
                <Image
                  src={playlist.authorImage}
                  alt="Playlist Author"
                  height={32}
                  width={32}
                  class="rounded-full"
                />
              {/key}
              <p class="text-sm">
                {playlist.authorName}
                {#key playlistPlaylengthQuery.dataUpdatedAt}
                  {#if playlistPlaylengthQuery.isSuccess}
                    <PlaylistLength
                      playlistTrackLength={playlistPlaylengthQuery.data.playlistTracksLength}
                    />
                  {/if}
                {/key}
              </p>
            </div>
            <div class="flex items-center gap-2 mt-4">
              <PlaylistPlayOptions tracks={playlistTracks} {context} />
              <ChangePlaylistVisibilityButton {...playlist} />
              {#if isTauri()}
                <DownloadButton source="playlist" tracks={playlistTracks} />
              {/if}
            </div>
          </div>
        </div>
        <div class="mt-4">
          {#if playlistTracksQuery.isLoading}
            <PlaylistTrackListSkeleton />
          {:else if playlistTracksQuery.isSuccess}
            <PlaylistTrackList {likedStatus} {playlist} {playlistTracks} />
          {/if}
        </div>
        {#if connectivityStore.isOnline}
          <RecommendedSongs {playlist} />
        {/if}
      </div>
    {:else if playlistQuery.isError}
      <div class="h-3/4 w-full flex items-center justify-center">
        <p class="text-5xl font-bold text-center text-balance text-red-500">
          An error occurred while loading the playlist.
        </p>
      </div>
    {/if}
  </div>
</Dialog.Root>
