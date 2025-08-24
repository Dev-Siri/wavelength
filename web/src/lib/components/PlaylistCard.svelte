<script lang="ts">
  import { EllipsisIcon, GlobeIcon, PencilIcon, PlayIcon, Trash2Icon } from "@lucide/svelte";
  import toast from "svelte-french-toast";

  import type { PlayList, PlayListTrack } from "$lib/db/schema.js";
  import type { ApiResponse } from "$lib/utils/types.js";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import playlistsStore from "$lib/stores/playlists.svelte";
  import userStore from "$lib/stores/user.svelte";
  import queryClient from "$lib/utils/query-client";

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
    playlist: PlayList;
    titleClasses?: string;
    imageClasses?: string;
    wrapperClasses?: string;
    wrapperClick?: () => void;
  } = $props();

  const { coverImage, name, playlistId, isPublic } = playlist;

  async function handleDeletePlaylist() {
    if (!userStore.user) return;

    const deletePlaylistResponse = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/${playlistId}`,
      {
        method: "DELETE",
      },
    );

    if (!deletePlaylistResponse.success) return toast.error("Failed to delete playlist.");

    toast.success(`Deleted playlist "${name}".`);

    const response = await queryClient<ApiResponse<PlayList[]>>(
      location.toString(),
      `/api/playlists/user/${userStore.user.email}`,
    );

    if (response.success) playlistsStore.playlists = response.data;
  }

  async function playPlaylist() {
    const playlistTracksResponse = await queryClient<ApiResponse<PlayListTrack[]>>(
      location.toString(),
      `/api/playlists/${playlistId}/tracks`,
      {
        customFetch: fetch,
      },
    );

    if (!playlistTracksResponse.success) return;

    musicQueueStore.musicQueue = [];
    musicQueueStore.addToQueue(...playlistTracksResponse.data);
    musicQueueStore.musicPlayingNow = playlistTracksResponse.data[0];
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
  <button type="button" class="relative" onclick={playPlaylist}>
    {#if coverImage}
      <Image
        src={coverImage}
        alt="Playlist Cover"
        height={40}
        width={40}
        class="rounded-md group-hover:opacity-50 duration-200 {imageClasses}"
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
          onclick={handleDeletePlaylist}
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
