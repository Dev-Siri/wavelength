<script lang="ts">
  import { Globe, MoreHorizontal, Pencil, Play, Trash2 } from "lucide-svelte";
  import toast from "svelte-french-toast";

  import type { PlayList, PlayListTrack } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";

  import { playMusic, visiblePanel } from "$lib/stores/music-player";
  import { addToQueue, musicPlayingNow, musicQueue } from "$lib/stores/music-queue";
  import { playlists } from "$lib/stores/playlists";
  import { user } from "$lib/stores/user";
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
    wrapperClick = () => {},
  }: {
    playlist: PlayList;
    titleClasses?: string;
    imageClasses?: string;
    wrapperClick?: () => void;
  } = $props();

  const { coverImage, name, playlistId, isPublic } = playlist;

  async function handleDeletePlaylist() {
    if (!$user) return;

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
      `/api/playlists/user/${$user.email}`,
    );

    if (response.success) $playlists = response.data;
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

    musicQueue.set([]);
    addToQueue(...playlistTracksResponse.data);
    musicPlayingNow.set(playlistTracksResponse.data[0]);
    playMusic();
    $visiblePanel = "playingNow";
  }
</script>

<div
  role="button"
  tabindex={0}
  onkeydown={wrapperClick}
  onclick={wrapperClick}
  class="{buttonVariants({
    variant: 'ghost',
  })} flex group cursor-pointer justify-start w-full gap-2 pl-1 pr-2 h-12"
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
    <Play
      class="absolute group-hover:opacity-100 opacity-0 inset-0 top-[34%] left-1/3"
      size={14}
      fill="white"
    />
  </button>
  <a
    class="w-full {titleClasses}"
    href="/playlist/{playlistId}"
    onclick={() => ($visiblePanel = null)}
  >
    <div class="text-start">
      <p class="text-md">{name}</p>
      <div class="flex">
        {#if isPublic}
          <Tooltip.Root>
            <Tooltip.Trigger>
              <Globe color="gray" size={12} />
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
      <DropdownMenu.Trigger class="ml-auto {titleClasses}">
        <MoreHorizontal class="text-muted-foreground" size={18} />
      </DropdownMenu.Trigger>
      <DropdownMenu.Content>
        <Dialog.Trigger class="w-full">
          <DropdownMenu.Item class="py-3 w-full gap-1 items-center">
            <Pencil size={16} />
            Edit details
          </DropdownMenu.Item>
        </Dialog.Trigger>
        <DropdownMenu.Item
          class="py-3 pr-20 gap-1 items-center text-red-500"
          onclick={handleDeletePlaylist}
        >
          <Trash2 size={16} />
          Delete playlist
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
    <Dialog.Content>
      <EditPlaylistDetailsDialog initialPlaylist={playlist} />
    </Dialog.Content>
  </Dialog.Root>
</div>
