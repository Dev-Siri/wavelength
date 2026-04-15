<script lang="ts">
  import { resolve } from "$app/paths";
  import {
    EllipsisIcon,
    GlobeIcon,
    MusicIcon,
    PencilIcon,
    PlayIcon,
    Trash2Icon,
  } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import type { Playlist } from "$lib/schemas/playlist";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import usePlaylistTracksQuery from "$lib/queries/playlistTracks";
  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { backendClient, reportErrorToBackend } from "$lib/utils/query-client";
  import { shuffleStartIndex } from "$lib/utils/shuffle";

  import EditPlaylistDetailsDialog from "../EditPlaylistDetailsDialog.svelte";
  import Image from "../Image.svelte";
  import Button from "../ui/button/button.svelte";
  import * as Dialog from "../ui/dialog";
  import * as DropdownMenu from "../ui/dropdown-menu";
  import * as Tooltip from "../ui/tooltip";

  const {
    playlist,
    wrapperClasses = "",
    wrapperClick = () => {},
    mode = "full",
  }: {
    playlist: Playlist;
    wrapperClasses?: string;
    wrapperClick?: () => void;
    mode?: "icon" | "full";
  } = $props();

  const { coverImage, name, playlistId, isPublic } = playlist;
  const queryClient = useQueryClient();

  const playlistTracksQuery = $derived(usePlaylistTracksQuery(playlistId));
  const playlistDeleteMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.deletePlaylist(playlistId),
    mutationFn: () =>
      backendClient(`/playlists/playlist/${playlistId}`, z.string(), { method: "DELETE" }),
    onError: () => toast.error("Failed to delete playlist."),
    onSuccess() {
      toast.success(`Deleted playlist "${name}".`);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.userPlaylists });
    },
  }));

  async function playPlaylist() {
    if (!playlistTracksQuery.data?.playlistTracks) return;

    try {
      const starterTrack =
        playlistTracksQuery.data.playlistTracks[
          shuffleStartIndex(playlistTracksQuery.data.playlistTracks.length)
        ];
      await musicPlayer.load(starterTrack, {
        type: "playlist",
        playlistId: playlistId,
        offlineTracks: playlistTracksQuery.data.playlistTracks,
      });
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "PlaylistTile: playPlaylist()",
      });
    }
  }

  const coverBtnProps = $derived(
    mode === "full" ? { onclick: playPlaylist } : { href: `/app/playlist/${playlistId}` },
  );
</script>

<div
  role="button"
  tabindex={0}
  onkeydown={wrapperClick}
  title={playlist.name}
  onclick={wrapperClick}
  class="flex group cursor-pointer items-center p-2.5 pr-3 hover:bg-[#1c1c1c] duration-200 my-0.5 rounded-xl w-full gap-2 {wrapperClasses} {mode ===
  'full'
    ? 'justify-start'
    : 'justify-center'}"
>
  <Button variant="outline" class="relative p-0 h-15 w-15 aspect-square" {...coverBtnProps}>
    {#if coverImage}
      <Image
        src={coverImage}
        alt="Playlist Cover"
        height={80}
        width={80}
        class="rounded-md h-15 w-15 aspect-square object-cover group-hover:opacity-50 duration-200"
      />
    {:else}
      <div
        class="bg-primary-foreground grid place-items-center rounded-md h-15 group-hover:opacity-50 duration-200 w-15"
      >
        <MusicIcon class="text-gray-300" />
      </div>
    {/if}
    {#if mode === "full"}
      <PlayIcon
        class="absolute cursor-pointer group-hover:opacity-100 opacity-0 inset-0 top-[34%] left-1/3"
        size={14}
        fill="white"
      />
    {/if}
  </Button>
  {#if mode === "full"}
    <a
      class="w-full"
      href={resolve(`/app/playlist/${playlistId}`)}
      onclick={() => (musicInterfaceStore.visiblePanel = null)}
    >
      <div class="text-start">
        <p class="text-md font-semibold">{name}</p>
        <div class="flex">
          {#if isPublic}
            <Tooltip.Root>
              <Tooltip.Trigger>
                <GlobeIcon color="gray" size={12} />
              </Tooltip.Trigger>
              <Tooltip.Content>Public</Tooltip.Content>
            </Tooltip.Root>
          {/if}
          <p
            class="text-xs text-muted-foreground font-medium bg-secondary py-0.5 px-1 mt-0.5 {isPublic
              ? 'ml-1'
              : ''}"
          >
            Playlist
          </p>
        </div>
      </div>
    </a>
    <Dialog.Root>
      <DropdownMenu.Root>
        <DropdownMenu.Trigger
          class="ml-auto cursor-pointer hover:bg-muted duration-200 h-fit w-fit p-1 rounded-full"
          aria-label="Playlist Options"
        >
          <EllipsisIcon class="text-muted-foreground" size={18} />
        </DropdownMenu.Trigger>
        <DropdownMenu.Content>
          <Dialog.Trigger class="w-full">
            <DropdownMenu.Item class="w-full">
              <PencilIcon size={16} />
              Edit details
            </DropdownMenu.Item>
          </Dialog.Trigger>
          <DropdownMenu.Item
            class="pr-20 text-red-500"
            onclick={() => playlistDeleteMutation.mutate()}
          >
            <Trash2Icon size={16} />
            Delete playlist
          </DropdownMenu.Item>
        </DropdownMenu.Content>
      </DropdownMenu.Root>
      <Dialog.Content>
        <EditPlaylistDetailsDialog initialPlaylist={playlist} />
      </Dialog.Content>
    </Dialog.Root>
  {/if}
</div>
