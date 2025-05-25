<script lang="ts">
  import { Clock, ListMusic, ListPlus, Play } from "lucide-svelte";
  import { fly } from "svelte/transition";

  import type { PageData } from "./$types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";
  import userStore from "$lib/stores/user.svelte";

  import ChangePlaylistVisibilityButton from "$lib/components/ChangePlaylistVisibilityButton.svelte";
  import EditPlaylistDetailsDialog from "$lib/components/EditPlaylistDetailsDialog.svelte";
  import Image from "$lib/components/Image.svelte";
  import PlaylistLength from "$lib/components/PlaylistLength.svelte";
  import PlaylistTracksList from "$lib/components/PlaylistTracksList.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Skeleton } from "$lib/components/ui/skeleton";
  import * as Tooltip from "$lib/components/ui/tooltip";

  const { data }: { data: PageData } = $props();

  let isRearrangingList = $state(false);

  function playPlaylist(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }
</script>

<Dialog.Root>
  <div
    class="flex flex-col h-full w-full bg-black rounded-2xl mt-8"
    in:fly={{ y: 20, duration: 100 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    {#await data.pageData.playlistInfoResponse}
      <div class="flex w-full p-4 gap-4">
        <Skeleton class="h-48 w-1/5 rounded-2xl" />
        <div class="flex flex-col mt-4 w-3/5 h-full gap-2">
          <Skeleton class="h-12 w-full rounded-full" />
          <Skeleton class="h-8 w-2/5 rounded-full" />
        </div>
      </div>
    {:then playlistData}
      {#if playlistData.success}
        <Dialog.Content>
          <EditPlaylistDetailsDialog initialPlaylist={playlistData.data} />
        </Dialog.Content>
        <div class="w-full p-4 pb-2 bg-black h-full mt-4 sm:mt-6 lg:mt-1 rounded-2xl">
          <div class="flex gap-4">
            {#if playlistData.data.coverImage}
              <Image
                src={playlistData.data.coverImage}
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
              {#if userStore.user?.email === playlistData.data.authorGoogleEmail}
                <Dialog.Trigger class="text-start cursor-pointer">
                  <h1 class="text-6xl font-extrabold">{playlistData.data.name}</h1>
                </Dialog.Trigger>
              {:else}
                <h1 class="text-6xl font-extrabold">{playlistData.data.name}</h1>
              {/if}
              <div class="flex gap-2 items-center mt-8">
                <Image
                  src={playlistData.data.authorImage}
                  alt="Playlist Author"
                  height={40}
                  width={40}
                  class="rounded-full"
                />
                <p class="font-semibold">
                  {playlistData.data.authorName}
                  {#await data.pageData.playlistPlaylengthResponse then playlistTrackLengthResponse}
                    {#if playlistTrackLengthResponse.success}
                      <PlaylistLength playlistTrackLength={playlistTrackLengthResponse.data} />
                    {/if}
                  {/await}
                </p>
              </div>
            </div>
          </div>
          <!-- for the music list -->
          <div class="h-full">
            {#await data.pageData.playlistTracksResponse then playlistTracks}
              {#if playlistTracks.success}
                {#if playlistTracks.data.length}
                  <div class="flex items-center gap-2">
                    <Button
                      class="rounded-full w-fit my-3 py-6 ml-1"
                      onclick={() => playPlaylist(playlistTracks.data)}
                    >
                      <Play class="text-primary-foreground" fill="black" />
                    </Button>
                    <ChangePlaylistVisibilityButton
                      playlistId={playlistData.data.playlistId}
                      isPublic={playlistData.data.isPublic}
                    />
                    <p class="text-muted-foreground ml-auto mr-4">
                      {playlistTracks.data.length} / 25 Tracks
                    </p>
                  </div>
                  <header
                    class="flex justify-around items-center gap-5 select-none text-muted-foreground"
                  >
                    <Tooltip.Root>
                      <Tooltip.Trigger>
                        <button
                          type="button"
                          class="text-white font-bold bg-muted p-1.5 rounded-full duration-200 hover:bg-secondary/90 {isRearrangingList
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
                    <PlaylistTracksList
                      playlistTracks={playlistTracks.data}
                      playlistId={playlistData.data.playlistId}
                      {isRearrangingList}
                    />
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
                <p class="text-center mt-20 text-red-500">
                  An error occured while loading music tracks
                </p>
              {/if}
            {/await}
          </div>
        </div>
      {/if}
    {/await}
  </div>
</Dialog.Root>
