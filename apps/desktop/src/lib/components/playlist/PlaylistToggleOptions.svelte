<script lang="ts">
  import { AlbumIcon, CheckIcon, DownloadIcon, MinusIcon, PlusIcon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";
  import { isTauri } from "@tauri-apps/api/core";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/utils/validation/music-track";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import downloadStore from "$lib/stores/download.svelte";
  import userStore from "$lib/stores/user.svelte";
  import {
    deleteDownload,
    getDownloadedStreamPath,
    isAlreadyDownloaded,
  } from "$lib/utils/download";
  import { backendClient } from "$lib/utils/query-client.js";
  import { playlistsSchema, type Playlist } from "$lib/utils/validation/playlists";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  import * as DropdownMenu from "../ui/dropdown-menu";

  const {
    music,
    toggle,
  }: {
    music: MusicTrack;
    toggle:
      | {
          type: "add";
        }
      | {
          type: "remove";
          from: Playlist;
        };
  } = $props();

  const queryClient = useQueryClient();
  const playlistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.userPlaylists,
    async queryFn() {
      if (!userStore.user) return;

      return backendClient(`/playlists/user/${userStore.user.email}`, playlistsSchema);
    },
  }));

  const playlistsAddMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.addToPlaylists,
    async mutationFn(playlistId: string) {
      let duration = music.duration;

      if (!duration) {
        const fetchedDuration = await backendClient(
          `/music/track/${music.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
      }

      return backendClient(`/playlists/playlist/${playlistId}/tracks`, z.string(), {
        method: "POST",
        body: {
          ...music,
          duration,
          videoType: "track",
        },
      });
    },
    onError: () => toast.error("Failed to update playlist."),
    onSuccess(data, playlistId) {
      toast.success(data);
      queryClient.invalidateQueries({
        queryKey: [
          ...svelteQueryKeys.playlist(playlistId),
          svelteQueryKeys.playlistTrack(playlistId),
        ],
      });
    },
  }));

  async function downloadTrack() {
    if (!isTauri()) return;

    if (await isAlreadyDownloaded(music.videoId)) {
      const { remove } = await import("@tauri-apps/plugin-fs");
      const trackPath = await getDownloadedStreamPath(music.videoId);
      await deleteDownload(music.videoId);
      await remove(trackPath);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.downloads });
      return;
    }

    downloadStore.addToQueue(music);
    const loadingToast = toast.loading(`Downloading ${music.title}`);

    setTimeout(() => toast.dismiss(loadingToast), 3000);
  }
</script>

{#if isTauri()}
  <DropdownMenu.Item onclick={downloadTrack}>
    {#await isAlreadyDownloaded(music.videoId) then isDownloaded}
      {#if isDownloaded}
        <CheckIcon />
        Saved
      {:else}
        <DownloadIcon />
        Save
      {/if}
    {/await}
  </DropdownMenu.Item>
{/if}
{#if music.album}
  <DropdownMenu.Item>
    <AlbumIcon />
    <a href="/app/album/{music.album.browseId}">Go to album</a>
  </DropdownMenu.Item>
{/if}
{#if toggle.type === "add"}
  {#if playlistsQuery.data?.playlists}
    <DropdownMenu.Sub>
      <DropdownMenu.SubTrigger>
        <PlusIcon size={20} />
        Add to playlist
      </DropdownMenu.SubTrigger>
      <DropdownMenu.SubContent>
        {#each playlistsQuery.data.playlists as playlist}
          <DropdownMenu.Item onclick={() => playlistsAddMutation.mutate(playlist.playlistId)}>
            {playlist.name}
          </DropdownMenu.Item>
        {/each}
      </DropdownMenu.SubContent>
    </DropdownMenu.Sub>
  {/if}
{:else}
  <DropdownMenu.Item
    onclick={() => playlistsAddMutation.mutate(toggle.from.playlistId)}
    class="text-red-400"
  >
    <MinusIcon size={20} /> Remove from playlist.
  </DropdownMenu.Item>
{/if}
