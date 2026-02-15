<script lang="ts">
  import { page } from "$app/state";
  import { ClockIcon, HashIcon, ListPlusIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { isTauri } from "@tauri-apps/api/core";

  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { playlistTracksSchema } from "$lib/utils/validation/playlist-track";

  import ChangePlaylistVisibilityButton from "$lib/components/action-buttons/ChangePlaylistVisibilityButton.svelte";
  import DownloadButton from "$lib/components/action-buttons/DownloadButton.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import PlaylistTracksList from "$lib/components/playlist/PlaylistTracksList.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";

  const { playlist }: { playlist: Playlist } = $props();

  let isRearrangingList = $state(false);

  const playlistTracksQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlistTrack(page.params.playlistId ?? ""),
    networkMode: "offlineFirst",
    queryFn: () =>
      backendClient(`/playlists/playlist/${page.params.playlistId}/tracks`, playlistTracksSchema),
  }));
</script>

<div class="h-full">
  {#if playlistTracksQuery.isLoading}
    <div class="w-full flex items-center justify-center py-20">
      <LoadingSpinner />
    </div>
  {:else if playlistTracksQuery.isSuccess}
    {@const { playlistTracks } = playlistTracksQuery.data}
    {#if playlistTracks.length}
      <div class="flex items-center gap-2 my-4">
        <PlaylistPlayOptions tracks={playlistTracks} />
        <ChangePlaylistVisibilityButton {...playlist} />
        {#if isTauri()}
          <DownloadButton source="playlist" tracks={playlistTracks} />
        {/if}
      </div>
      <header class="flex items-center select-none text-muted-foreground">
        <section class="flex items-center gap-10 w-1/3">
          <Tooltip.Root>
            <Tooltip.Trigger>
              <button
                type="button"
                class="cursor-pointer p-1.5 rounded-full duration-200"
                onclick={() => (isRearrangingList = !isRearrangingList)}
              >
                <HashIcon size={14} />
              </button>
            </Tooltip.Trigger>
            <Tooltip.Content>
              <p>
                {isRearrangingList ? "Stop" : "Enable"} Rearranging Tracks
              </p>
            </Tooltip.Content>
          </Tooltip.Root>
          <p class="text-sm">Title</p>
        </section>
        <section class="flex justify-center w-1/3">
          <p class="text-sm">Album</p>
        </section>
        <section class="flex justify-center w-1/3">
          <ClockIcon size={14} class="mr-6" />
        </section>
      </header>
      <div class="bg-secondary h-[1px] w-full my-2.5 rounded-full"></div>
      <div class="mt-2 overflow-x-hidden pb-[20%]">
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
