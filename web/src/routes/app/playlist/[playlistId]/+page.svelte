<script lang="ts">
  import { page } from "$app/state";
  import { ClockIcon, ListMusicIcon, ListPlusIcon, PlayIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";

  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import userStore from "$lib/stores/user.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import {
    playlistTrackLengthSchema,
    playlistTracksSchema,
  } from "$lib/utils/validation/playlist-track";
  import { playlistSchema } from "$lib/utils/validation/playlists.js";
  import { themeColorSchema } from "$lib/utils/validation/theme-color";

  import ChangePlaylistVisibilityButton from "$lib/components/ChangePlaylistVisibilityButton.svelte";
  import EditPlaylistDetailsDialog from "$lib/components/EditPlaylistDetailsDialog.svelte";
  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import PlaylistLength from "$lib/components/PlaylistLength.svelte";
  import PlaylistTracksList from "$lib/components/PlaylistTracksList.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import * as Tooltip from "$lib/components/ui/tooltip";

  let isRearrangingList = $state(false);
  let pageTitle = $state("Playlist");

  function playPlaylist(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }

  const playlistQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlist(page.params.playlistId ?? ""),
    queryFn: () => backendClient(`/playlists/playlist/${page.params.playlistId}`, playlistSchema),
  }));

  const playlistTracksQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlistTrack(page.params.playlistId ?? ""),
    queryFn: () =>
      backendClient(`/playlists/playlist/${page.params.playlistId}/tracks`, playlistTracksSchema),
  }));

  const playlistPlaylengthQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlistTrackLength(page.params.playlistId ?? ""),
    queryFn: () =>
      backendClient(
        `/playlists/playlist/${page.params.playlistId}/length`,
        playlistTrackLengthSchema,
      ),
  }));

  let playlistThumbnailUrl = $derived(playlistQuery.data?.coverImage ?? "");

  const playlistThemeColorQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.themeColor(playlistThumbnailUrl),
    queryFn() {
      if (!playlistThumbnailUrl) return;

      return backendClient(`/image/theme-color`, themeColorSchema, {
        searchParams: { imageUrl: playlistThumbnailUrl },
      });
    },
  }));

  $effect(() => {
    if (playlistQuery.isSuccess) pageTitle = `${playlistQuery.data.name}`;
  });
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<Dialog.Root>
  <div
    class="flex flex-col h-full w-full bg-black rounded-2xl overflow-y-auto"
    in:fly={{ y: 20, duration: 100 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    {#if playlistQuery.isLoading}
      <div class="h-3/4 w-full flex items-center justify-center">
        <LoadingSpinner />
      </div>
    {:else if playlistQuery.isSuccess}
      {@const playlist = playlistQuery.data}
      <Dialog.Content>
        <EditPlaylistDetailsDialog initialPlaylist={playlist} />
      </Dialog.Content>
      <div class="relative w-full p-4 pb-2 bg-black h-full mt-4 sm:mt-6 lg:mt-1 rounded-2xl">
        {#if playlistThemeColorQuery.isSuccess && playlistThemeColorQuery.data}
          <div
            class="absolute duration-200 h-1/2 z-0 inset-0 pointer-events-none"
            style="
        background: linear-gradient(to bottom, rgb({playlistThemeColorQuery.data
              .r}, {playlistThemeColorQuery.data.g}, {playlistThemeColorQuery.data
              .b}), transparent);
        opacity: 0.5;
      "
          ></div>
        {/if}
        <div class="relative flex gap-4 mt-4">
          {#if playlist.coverImage}
            {#key playlist}
              <Image
                src={playlist.coverImage}
                alt="Playlist Cover"
                class="h-48 w-48 rounded-2xl aspect-square"
                height={192}
                width={192}
              />
            {/key}
          {:else}
            <div class="h-48 w-48 rounded-2xl aspect-square bg-muted"></div>
          {/if}
          <div class="flex flex-col w-3/5 h-full gap-2">
            <span class="text-lg ml-0.5 select-none">Playlist</span>
            {#if userStore.user?.email === playlist.authorGoogleEmail}
              <Dialog.Trigger class="text-start cursor-pointer">
                <h1 class="text-6xl font-extrabold">{playlist.name}</h1>
              </Dialog.Trigger>
            {:else}
              <h1 class="text-6xl font-extrabold">{playlist.name}</h1>
            {/if}
            <div class="flex gap-2 items-center mt-8">
              {#key playlist.authorImage}
                <Image
                  src={playlist.authorImage}
                  alt="Playlist Author"
                  height={40}
                  width={40}
                  class="rounded-full"
                />
              {/key}
              <p class="font-semibold">
                {playlist.authorName}
                {#key playlistPlaylengthQuery.dataUpdatedAt}
                  {#if playlistPlaylengthQuery.isSuccess}
                    <PlaylistLength playlistTrackLength={playlistPlaylengthQuery.data} />
                  {/if}
                {/key}
              </p>
            </div>
          </div>
        </div>
        <!-- for the music list -->
        <div class="h-full bg-black">
          {#if playlistTracksQuery.isLoading}
            <div class="w-full flex items-center justify-center py-20">
              <LoadingSpinner />
            </div>
          {:else if playlistTracksQuery.isSuccess}
            {@const playlistTracks = playlistTracksQuery.data}
            {#if playlistTracks.length}
              <div class="flex items-center gap-2">
                <Button
                  class="rounded-full w-fit my-3 py-6 ml-1 z-10"
                  onclick={() => playPlaylist(playlistTracks ?? [])}
                >
                  <PlayIcon class="text-primary-foreground" fill="black" />
                </Button>
                <div class="z-10">
                  <ChangePlaylistVisibilityButton
                    playlistId={playlist.playlistId}
                    isPublic={playlist.isPublic}
                  />
                </div>
              </div>
              <header
                class="flex justify-around items-center gap-5 select-none text-muted-foreground"
              >
                <Tooltip.Root>
                  <Tooltip.Trigger>
                    <button
                      type="button"
                      class="text-white cursor-pointer font-bold bg-muted p-1.5 rounded-full duration-200 hover:bg-secondary/90 {isRearrangingList
                        ? 'animate-bounce'
                        : ''}"
                      onclick={() => (isRearrangingList = !isRearrangingList)}
                    >
                      <ListMusicIcon size={18} />
                    </button>
                  </Tooltip.Trigger>
                  <Tooltip.Content>
                    <p>
                      {isRearrangingList ? "Stop" : "Enable"} Rearranging Tracks
                    </p>
                  </Tooltip.Content>
                </Tooltip.Root>
                <p class="flex-2">Title</p>
                <ClockIcon size={18} class="mr-[62px]" />
              </header>
              <div class="mt-2 overflow-x-hidden pb-[80%] md:pb-[40%] lg:pb-[20%]">
                {#key playlistTracks}
                  <PlaylistTracksList {playlistTracks} {playlist} {isRearrangingList} />
                {/key}
              </div>
            {:else}
              <div class="mt-10 flex gap-2 flex-col items-center justify-center">
                <ListPlusIcon size={40} />
                <h4 class="text-center text-2xl">Your playlist is empty</h4>
                <Button
                  variant="secondary"
                  onclick={() => document.getElementById("search-input")?.focus()}
                >
                  Discover new music
                </Button>
              </div>
            {/if}
          {/if}
        </div>
      </div>
    {:else}
      <div class="h-3/4 w-full flex items-center justify-center">
        <p class="text-5xl font-bold text-center text-balance text-red-500">
          An error occurred while loading the playlist.
        </p>
      </div>
    {/if}
  </div>
</Dialog.Root>
