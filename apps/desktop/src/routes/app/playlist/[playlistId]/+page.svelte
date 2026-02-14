<script lang="ts">
  import { page } from "$app/state";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";
  import { z } from "zod";

  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import userStore from "$lib/stores/user.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { playlistSchema } from "$lib/utils/validation/playlists.js";
  import { playlistTracksLengthSchema } from "$lib/utils/validation/track-length";

  import EditPlaylistDetailsDialog from "$lib/components/EditPlaylistDetailsDialog.svelte";
  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import PlaylistLength from "$lib/components/playlist/PlaylistLength.svelte";
  import * as Dialog from "$lib/components/ui/dialog";
  import { MusicIcon } from "@lucide/svelte";
  import PlaylistInteractableTracksList from "./playlist-interactable-tracks-list.svelte";
  import PlaylistThemeGradient from "./playlist-theme-gradient.svelte";

  let pageTitle = $state("Playlist");

  const playlistQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlist(page.params.playlistId ?? ""),
    networkMode: "offlineFirst",
    queryFn: () =>
      backendClient(
        `/playlists/playlist/${page.params.playlistId}`,
        z.object({ playlist: playlistSchema }),
      ),
  }));

  const playlistPlaylengthQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlistTrackLength(page.params.playlistId ?? ""),
    networkMode: "offlineFirst",
    queryFn: () =>
      backendClient(
        `/playlists/playlist/${page.params.playlistId}/length`,
        playlistTracksLengthSchema,
      ),
  }));

  const playlistCover = $derived(playlistQuery.data?.playlist.coverImage ?? "");

  $effect(() => {
    if (playlistQuery.isSuccess) pageTitle = `${playlistQuery.data.playlist.name}`;
  });
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<Dialog.Root>
  <div
    class="flex flex-col h-full w-full bg-black rounded-2xl overflow-y-auto"
    in:fly={{ y: 20, duration: 250 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    {#if playlistQuery.isLoading}
      <div class="h-3/4 w-full flex items-center justify-center">
        <LoadingSpinner />
      </div>
    {:else if playlistQuery.isSuccess}
      {@const { playlist } = playlistQuery.data}
      <EditPlaylistDetailsDialog initialPlaylist={playlist} />
      <div class="relative w-full p-4 pb-2 bg-black h-full mt-4 sm:mt-6 lg:mt-1 rounded-2xl">
        <PlaylistThemeGradient {playlistCover} />
        <div class="relative flex gap-4">
          {#if playlist.coverImage}
            {#key playlist}
              <Image
                src={playlist.coverImage}
                alt="Playlist Cover"
                class="h-56 w-56  rounded-2xl  aspect-square"
                height={224}
                width={224}
              />
            {/key}
          {:else}
            <div class="h-56 w-56 grid place-items-center rounded-2xl aspect-square bg-muted">
              <MusicIcon class="text-gray-300" size={60} />
            </div>
          {/if}
          <div class="flex flex-col justify-center w-3/5 h-52 gap-2">
            <span class="text-sm ml-0.5 select-none">Playlist</span>
            {#if userStore.user?.email === playlist.authorGoogleEmail}
              <Dialog.Trigger class="text-start cursor-pointer">
                <h1 class="text-6xl lg:text-7xl font-black text-balance">{playlist.name}</h1>
              </Dialog.Trigger>
            {:else}
              <h1 class="text-6xl lg:text-7xl font-black text-balance">{playlist.name}</h1>
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
          </div>
        </div>
        <PlaylistInteractableTracksList {playlist} />
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
