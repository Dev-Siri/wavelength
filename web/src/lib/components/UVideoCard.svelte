<script lang="ts">
  import { invalidate } from "$app/navigation";
  import { EllipsisIcon, PlusIcon } from "@lucide/svelte";
  import toast from "svelte-french-toast";
  // import createYouTubePlayer from "youtube-player";

  import type { ApiResponse, YouTubeVideo } from "$lib/types.js";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import playlistsStore from "$lib/stores/playlists.svelte.js";
  import { parseHtmlEntities } from "$lib/utils/format.js";
  import { backendClient } from "$lib/utils/query-client.js";

  import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import { getThumbnailUrl } from "$lib/utils/url";
  import Image from "./Image.svelte";

  const { uvideo }: { uvideo: YouTubeVideo } = $props();

  let tempDiv: HTMLDivElement | null = $state(null);

  async function playYtVideo() {
    const queueableTrack = {
      ...uvideo,
      author: uvideo.author,
      videoType: "uvideo",
    } satisfies QueueableMusic;

    musicQueueStore.addToQueue(queueableTrack);
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }

  async function addToPlaylist(playlistId: string) {
    if (!tempDiv) return;

    // const tempPlayerInstance = createYouTubePlayer(tempDiv, {
    //   videoId: uvideo.videoId,
    // });

    // const duration = durationify(await tempPlayerInstance.getDuration());

    // tempPlayerInstance.destroy();

    const response = await backendClient<ApiResponse<string>>(
      `/playlists/playlist/${playlistId}/tracks`,
      {
        method: "POST",
        body: {
          author: uvideo.author,
          title: uvideo.title,
          videoId: uvideo.videoId,
          // duration,
          isExplicit: false,
          thumbnail: getThumbnailUrl(uvideo.videoId),
          videoType: "uvideo",
        },
      },
    );

    if (response.success) {
      toast.success(response.data);
      invalidate(url => url.pathname.startsWith("/playlist"));
      return;
    }

    toast.error("Failed to update playlist.");
  }
</script>

<!-- temp div to retrieve length of vid -->
<div class="hidden" id="temp-player-{uvideo.videoId}" bind:this={tempDiv}></div>
<DropdownMenu.Root>
  <button type="button" class="relative rounded-2xl group" onclick={playYtVideo}>
    <Image
      src={uvideo.thumbnail}
      height={250}
      width={310}
      alt="YT Video Thumbnail"
      class="rounded-2xl h-[200px] object-cover opacity-75 group-hover:opacity-100 duration-200"
    />
    <div class="fade-shadow"></div>
    <Tooltip.Root>
      <Tooltip.Trigger
        class="absolute bottom-0 w-full right-0 p-4 text-xl text-left font-semibold opacity-100 z-40"
      >
        <p class="text-start">
          {parseHtmlEntities(
            uvideo.title.length > 40
              ? `${uvideo.title.slice(0, 39) ?? ""}..`
              : (uvideo.title ?? ""),
          )}
        </p>
      </Tooltip.Trigger>
      <Tooltip.Content>
        <p>{parseHtmlEntities(uvideo.title ?? "")}</p>
      </Tooltip.Content>
    </Tooltip.Root>
    <div
      class="absolute flex inset-0 bottom-auto justify-between w-full left-auto z-40 pr-4 pt-2"
      role="presentation"
      onclick={e => e.stopImmediatePropagation()}
    >
      <DropdownMenu.Trigger>
        <button
          type="button"
          class="flex items-center ml-2 hover:text-white duration-200 justify-center px-1 text-muted-foreground"
        >
          <EllipsisIcon />
        </button>
      </DropdownMenu.Trigger>
      <p class="font-bold">
        {uvideo.author}
      </p>
    </div>
  </button>
  <DropdownMenu.Content>
    {#each playlistsStore.playlists as playlist}
      <DropdownMenu.Item onclick={() => addToPlaylist(playlist.playlistId)} class="flex py-3 gap-2">
        <PlusIcon size={20} /> Add or Remove from Playlist "{playlist.name}"
      </DropdownMenu.Item>
    {/each}
  </DropdownMenu.Content>
</DropdownMenu.Root>

<style>
  .fade-shadow {
    position: absolute;
    inset: 0;
    background:
      linear-gradient(to top, rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0)),
      linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0));
    z-index: 40;
    border-radius: inherit;
  }
</style>
