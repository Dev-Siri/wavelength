<script lang="ts" module>
  export type PlaylistToggle =
    | {
        type: "add";
      }
    | {
        type: "remove";
        from: Playlist;
      };
</script>

<script lang="ts">
  import { resolve } from "$app/paths";
  import {
    AlbumIcon,
    CheckIcon,
    DownloadIcon,
    ListPlusIcon,
    MinusIcon,
    PlusIcon,
  } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { isTauri } from "@tauri-apps/api/core";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/schemas/music-track";
  import { type Playlist, type PlaylistVideoType } from "$lib/schemas/playlist";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { deleteDownload, isDownloaded } from "$lib/ipc/download";
  import useUserPlaylistsQuery from "$lib/queries/userPlaylists";
  import { musicTrackDurationSchema } from "$lib/schemas/track-length";
  import downloadStore from "$lib/stores/download.svelte";
  import userStore from "$lib/stores/user.svelte";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";
  import { backendClient } from "$lib/utils/query-client.js";

  import * as ContextMenu from "../ui/context-menu";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const {
    music,
    toggle,
    videoType = "VIDEO_TYPE_TRACK",
    ui,
  }: {
    music: MusicTrack;
    videoType?: PlaylistVideoType;
    ui: "dropdown" | "contextmenu";
    toggle: PlaylistToggle;
  } = $props();

  const queryClient = useQueryClient();
  const userPlaylistsQuery = $derived(useUserPlaylistsQuery(userStore.user?.email ?? ""));

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
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlistTrack(playlistId) });
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlistTrackLength(playlistId) });
    },
  }));

  async function downloadTrack() {
    if (!isTauri()) return;

    if (await isDownloaded(music.videoId)) {
      await deleteDownload(music.videoId);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.downloads });
      return;
    }

    downloadStore.addToQueue(music);
    const loadingToast = toast.loading(`Downloading ${music.title}`);

    setTimeout(() => toast.dismiss(loadingToast), 3000);
  }

  const Menu = $derived(ui === "dropdown" ? DropdownMenu : ContextMenu);
</script>

{#if isTauri()}
  <Menu.Item onclick={downloadTrack}>
    {#await isDownloaded(music.videoId) then isDownloaded}
      {#if isDownloaded}
        <CheckIcon />
        Saved
      {:else}
        <DownloadIcon />
        Save
      {/if}
    {/await}
  </Menu.Item>
{/if}
{#if music.album}
  <Menu.Item
    onclick={() =>
      musicPlayer.queue.addToQueue({
        ...music,
        videoType,
      })}
  >
    <ListPlusIcon />
    <span>Add to queue</span>
  </Menu.Item>
  <Menu.Item>
    <AlbumIcon />
    <a href={resolve(`/app/album/${music.album.browseId}`)}>Go to album</a>
  </Menu.Item>
{/if}
{#if toggle.type === "add"}
  {#if userPlaylistsQuery.data?.playlists}
    <Menu.Sub>
      <Menu.SubTrigger>
        <PlusIcon size={20} />
        Add to playlist
      </Menu.SubTrigger>
      <Menu.SubContent>
        {#each userPlaylistsQuery.data.playlists as playlist (`add-to-${playlist.playlistId}`)}
          <Menu.Item onclick={() => playlistsAddMutation.mutate(playlist.playlistId)}>
            {playlist.name}
          </Menu.Item>
        {/each}
      </Menu.SubContent>
    </Menu.Sub>
  {/if}
{:else if toggle.type === "remove"}
  <Menu.Item onclick={() => playlistsAddMutation.mutate(toggle.from.playlistId)}>
    <MinusIcon size={20} /> Remove from playlist.
  </Menu.Item>
{/if}
