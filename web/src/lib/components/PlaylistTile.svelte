<script lang="ts">
  import { EllipsisIcon, GlobeIcon, PencilIcon, PlayIcon, Trash2Icon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { backendClient } from "$lib/utils/query-client";
  import { playlistTracksSchema } from "$lib/utils/validation/playlist-track";

  import EditPlaylistDetailsDialog from "./EditPlaylistDetailsDialog.svelte";
  import Image from "./Image.svelte";
  import Button from "./ui/button/button.svelte";
  import * as Dialog from "./ui/dialog";
  import * as DropdownMenu from "./ui/dropdown-menu";
  import * as Tooltip from "./ui/tooltip";

  const {
    playlist,
    titleClasses = "",
    wrapperClasses = "",
    wrapperClick = () => {},
  }: {
    playlist: Playlist;
    titleClasses?: string;
    wrapperClasses?: string;
    wrapperClick?: () => void;
  } = $props();

  const { coverImage, name, playlistId, isPublic } = playlist;
  const queryClient = useQueryClient();

  const playlistTracksQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.playlistTrack(playlistId ?? ""),
    queryFn: () => backendClient(`/playlists/playlist/${playlistId}/tracks`, playlistTracksSchema),
  }));

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

    musicQueueStore.musicQueue = [];
    musicQueueStore.addToQueue(...playlistTracksQuery.data.playlistTracks);
    musicQueueStore.musicPlayingNow = playlistTracksQuery.data.playlistTracks[0];
    musicPlayerStore.playMusic();
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  role="button"
  tabindex={0}
  onkeydown={wrapperClick}
  onclick={wrapperClick}
  class="flex group cursor-pointer items-center justify-start p-2.5 pr-3 bg-[#111] hover:bg-[#1c1c1c] duration-200 my-0.5 rounded-xl w-full gap-2 {wrapperClasses}"
>
  <Button variant="outline" class="relative p-0 h-15 w-15 aspect-square" onclick={playPlaylist}>
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
        class="bg-primary-foreground rounded-md h-15 group-hover:opacity-50 duration-200 w-15"
      ></div>
    {/if}
    <PlayIcon
      class="absolute cursor-pointer group-hover:opacity-100 opacity-0 inset-0 top-[34%] left-1/3"
      size={14}
      fill="white"
    />
  </Button>
  <a
    class="w-full {titleClasses}"
    href="/app/playlist/{playlistId}"
    onclick={() => (musicPlayerStore.visiblePanel = null)}
  >
    <div class="text-start">
      <p class="text-md">{name}</p>
      <div class="flex">
        {#if isPublic}
          <Tooltip.Root>
            <Tooltip.Trigger>
              <GlobeIcon color="gray" size={12} />
            </Tooltip.Trigger>
            <Tooltip.Content>Public</Tooltip.Content>
          </Tooltip.Root>
        {/if}
        <p class="text-xs text-muted-foreground {isPublic ? 'ml-1' : ''}">Playlist</p>
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
          <DropdownMenu.Item class="py-3 w-full gap-1 items-center">
            <PencilIcon size={16} />
            Edit details
          </DropdownMenu.Item>
        </Dialog.Trigger>
        <DropdownMenu.Item
          class="py-3 pr-20 gap-1 items-center text-red-500"
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
</div>
