<script lang="ts">
  import { EllipsisIcon, GlobeIcon, PencilIcon, PlayIcon, Trash2Icon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { PlaylistTrack } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { backendClient } from "$lib/utils/query-client";

  import EditPlaylistDetailsDialog from "./EditPlaylistDetailsDialog.svelte";
  import Image from "./Image.svelte";
  import { buttonVariants } from "./ui/button";
  import * as Dialog from "./ui/dialog";
  import * as DropdownMenu from "./ui/dropdown-menu";
  import * as Tooltip from "./ui/tooltip";

  const {
    playlist,
    titleClasses = "",
    imageClasses = "w-14 h-10",
    wrapperClasses = "",
    wrapperClick = () => {},
  }: {
    playlist: Playlist;
    titleClasses?: string;
    imageClasses?: string;
    wrapperClasses?: string;
    wrapperClick?: () => void;
  } = $props();

  const { coverImage, name, playlistId, isPublic } = playlist;
  const queryClient = useQueryClient();

  let playlistTracks = $derived.by(() =>
    queryClient.getQueryData<PlaylistTrack[]>(svelteQueryKeys.playlistTrack(playlistId)),
  );

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
    if (!playlistTracks) return;

    musicQueueStore.musicQueue = [];
    musicQueueStore.addToQueue(...playlistTracks);
    musicQueueStore.musicPlayingNow = playlistTracks[0];
    musicPlayerStore.playMusic();
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  role="button"
  tabindex={0}
  onkeydown={wrapperClick}
  onclick={wrapperClick}
  class="{buttonVariants({
    variant: 'ghost',
  })} flex group cursor-pointer justify-start w-full gap-2 pl-1 pr-2 h-12 {wrapperClasses}"
>
  <button type="button" class="relative {imageClasses}" onclick={playPlaylist}>
    {#if coverImage}
      <Image
        src={coverImage}
        alt="Playlist Cover"
        height={40}
        width={40}
        class="rounded-md h-full w-full object-cover group-hover:opacity-50 duration-200"
      />
    {:else}
      <div
        class="bg-primary-foreground rounded-md h-10 group-hover:opacity-50 duration-200 w-[40px]"
      ></div>
    {/if}
    <PlayIcon
      class="absolute cursor-pointer group-hover:opacity-100 opacity-0 inset-0 top-[34%] left-1/3"
      size={14}
      fill="white"
    />
  </button>
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
      <DropdownMenu.Trigger class="ml-auto cursor-pointer {titleClasses}">
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
