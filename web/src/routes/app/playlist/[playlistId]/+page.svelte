<script lang="ts">
  import { Clock, ListMusic, ListPlus, Play } from "lucide-svelte";
  import { fly } from "svelte/transition";

  import type { PlayList, PlayListTrack } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";
  import type { PageData } from "./$types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";
  import userStore from "$lib/stores/user.svelte";
  import queryClient from "$lib/utils/query-client";

  import { page } from "$app/state";
  import ChangePlaylistVisibilityButton from "$lib/components/ChangePlaylistVisibilityButton.svelte";
  import EditPlaylistDetailsDialog from "$lib/components/EditPlaylistDetailsDialog.svelte";
  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import PlaylistLength from "$lib/components/PlaylistLength.svelte";
  import PlaylistTracksList from "$lib/components/PlaylistTracksList.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import getClientDB from "$lib/db/client-indexed-db";

  const { data }: { data: PageData } = $props();

  let playlist = $state(data.pageData.cachedPlaylist);
  let playlistTracks = $state(data.pageData.cachedPlaylistTracks);
  let isRearrangingList = $state(false);
  let pageTitle = $state("Playlist - Wavelength");

  function playPlaylist(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }

  $effect(() => {
    playlist = data.pageData.cachedPlaylist;
    playlistTracks = data.pageData.cachedPlaylistTracks;
  });

  $effect(() => {
    async function fetchPlaylistData() {
      if (!page.params.playlistId) return;

      const [playlistInfoResponse, playlistTracksResponse] = await Promise.all([
        queryClient<ApiResponse<PlayList>>(
          location.origin,
          `/api/playlists/${page.params.playlistId}`,
        ),
        queryClient<ApiResponse<PlayListTrack[]>>(
          location.origin,
          `/api/playlists/${page.params.playlistId}/tracks`,
        ),
      ]);

      const db = await getClientDB();

      if (playlistInfoResponse.success) {
        playlist = playlistInfoResponse.data;
        pageTitle = `${playlist.name} - Wavelength`;

        db.put("playlists", playlistInfoResponse.data);
      } else return (pageTitle = "An Error Occurred While Retrieving Playlist.");

      if (playlistTracksResponse.success) {
        playlistTracks = playlistTracksResponse.data;

        const tx = db.transaction("tracks", "readwrite");
        const store = tx.objectStore("tracks");

        playlistTracks.forEach(track => {
          const {
            playlistId,
            playlistTrackId,
            title,
            thumbnail,
            positionInPlaylist,
            isExplicit,
            author,
            duration,
            videoId,
            videoType,
          } = track;

          store.put({
            playlistId,
            playlistTrackId,
            title,
            thumbnail,
            positionInPlaylist,
            isExplicit,
            author,
            duration,
            videoId,
            videoType,
          });
        });
        await tx.done;
      } else return (pageTitle = "An Error Occurred While Retrieving Playlist.");
    }

    try {
      fetchPlaylistData();
    } catch (err) {
      console.log(err);
    }
  });
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<Dialog.Root>
  <div
    class="flex flex-col h-full w-full bg-black rounded-2xl mt-8"
    in:fly={{ y: 20, duration: 100 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    {#if data.success}
      {#if playlist}
        <Dialog.Content>
          <EditPlaylistDetailsDialog initialPlaylist={playlist} />
        </Dialog.Content>
        <div class="w-full p-4 pb-2 bg-black h-full mt-4 sm:mt-6 lg:mt-1 rounded-2xl">
          <div class="flex gap-4">
            {#if playlist.coverImage}
              <Image
                src={playlist.coverImage}
                alt="Playlist Cover"
                class="h-48 w-48 rounded-2xl aspect-square"
                height={192}
                width={192}
              />
            {:else}
              <div class="h-48 w-1/5 rounded-2xl bg-muted"></div>
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
                <Image
                  src={playlist.authorImage}
                  alt="Playlist Author"
                  height={40}
                  width={40}
                  class="rounded-full"
                />
                <p class="font-semibold">
                  {playlist.authorName}
                  {#if data.pageData.playlistPlaylengthResponse}
                    {#await data.pageData.playlistPlaylengthResponse then playlistTrackLengthResponse}
                      {#if playlistTrackLengthResponse.success}
                        <PlaylistLength playlistTrackLength={playlistTrackLengthResponse.data} />
                      {/if}
                    {/await}
                  {/if}
                </p>
              </div>
            </div>
          </div>
          <!-- for the music list -->
          <div class="h-full">
            {#if playlistTracks}
              {#if playlistTracks.length}
                <div class="flex items-center gap-2">
                  <Button
                    class="rounded-full w-fit my-3 py-6 ml-1"
                    onclick={() => playPlaylist(playlistTracks ?? [])}
                  >
                    <Play class="text-primary-foreground" fill="black" />
                  </Button>
                  <ChangePlaylistVisibilityButton
                    playlistId={playlist.playlistId}
                    isPublic={playlist.isPublic}
                  />
                  <p class="text-muted-foreground ml-auto mr-4">
                    {playlistTracks.length} / 40 Tracks
                  </p>
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
                        <ListMusic size={18} />
                      </button>
                    </Tooltip.Trigger>
                    <Tooltip.Content>
                      <p>
                        {isRearrangingList ? "Stop" : "Enable"} Rearranging Tracks
                      </p>
                    </Tooltip.Content>
                  </Tooltip.Root>
                  <p class="flex-2">Title</p>
                  <Clock size={18} class="mr-[62px]" />
                </header>
                <div class="h-2/4 pb-[40%] min-660:pb-[35%] overflow-y-auto overflow-x-hidden">
                  {#key playlistTracks}
                    <PlaylistTracksList
                      {playlistTracks}
                      playlistId={playlist.playlistId}
                      {isRearrangingList}
                    />
                  {/key}
                </div>
              {:else}
                <div class="mt-10 flex gap-2 flex-col items-center justify-center">
                  <ListPlus size={40} />
                  <h4 class="text-center text-2xl">Your playlist is empty</h4>
                  <Button
                    variant="secondary"
                    onclick={() => document.getElementById("search-input")?.focus()}
                  >
                    Discover new music
                  </Button>
                </div>
              {/if}
            {:else}
              <div class="w-full flex items-center justify-center py-20">
                <LoadingSpinner />
              </div>
            {/if}
          </div>
        </div>
      {:else}
        <div class="h-3/4 w-full flex items-center justify-center">
          <LoadingSpinner />
        </div>
      {/if}
    {:else}
      <div class="h-3/4 w-full flex items-center justify-center">
        <p class="text-5xl font-bold text-center text-balance text-red-500">
          An error occurred while loading the playlist.
        </p>
      </div>
    {/if}
  </div>
</Dialog.Root>
