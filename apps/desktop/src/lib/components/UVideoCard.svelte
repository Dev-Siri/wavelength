<script lang="ts">
  import { EllipsisIcon, PlusIcon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import { playlistsSchema } from "$lib/utils/validation/playlists";
  import type { YouTubeVideo } from "$lib/utils/validation/youtube-video";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import userStore from "$lib/stores/user.svelte";
  import { backendClient } from "$lib/utils/query-client.js";
  import { getThumbnailUrl } from "$lib/utils/url";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import Image from "./Image.svelte";

  const { uvideo }: { uvideo: YouTubeVideo } = $props();

  const queryClient = useQueryClient();
  const playlistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.userPlaylists,
    async queryFn() {
      if (!userStore.user) return;

      return backendClient(`/playlists/user/${userStore.user.email}`, playlistsSchema);
    },
  }));

  async function playYtVideo() {
    const queueableTrack = {
      ...uvideo,
      artists: [
        {
          title: uvideo.author,
          browseId: uvideo.authorChannelId,
        },
      ],
      videoType: "VIDEO_TYPE_UVIDEO",
    } satisfies QueueableMusic;

    musicQueueStore.musicPlayingNow = queueableTrack;
    musicQueueStore.musicPlaylistContext = [];
    musicPlayerStore.visiblePanel = "playingNow";
  }

  const addToPlaylistMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.addUVideoToPlaylist,
    onError: () => toast.error("Failed to update playlist."),
    onSuccess(data: string, playlistId: string) {
      toast.success(data);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlist(playlistId) });
    },
    async mutationFn(playlistId: string) {
      const duration = await backendClient(
        `/music/track/${uvideo.videoId}/duration`,
        musicTrackDurationSchema,
      );

      return backendClient(`/playlists/playlist/${playlistId}/tracks`, z.string(), {
        method: "POST",
        body: {
          artists: [
            {
              title: uvideo.author,
              browseId: uvideo.authorChannelId,
            },
          ],
          title: uvideo.title,
          videoId: uvideo.videoId,
          duration: duration.durationSeconds.toString(),
          isExplicit: false,
          thumbnail: getThumbnailUrl(uvideo.videoId),
          videoType: "uvideo",
        },
      });
    },
  }));
</script>

<DropdownMenu.Root>
  <button type="button" class="relative rounded-2xl group" onclick={playYtVideo}>
    {#key uvideo.thumbnail}
      <Image
        src={uvideo.thumbnail}
        height={300}
        width={360}
        alt="YouTube Video Thumbnail"
        class="rounded-2xl h-full w-full object-cover opacity-75 group-hover:opacity-100 duration-200"
      />
    {/key}
    <div class="fade-shadow"></div>
    <Tooltip.Root>
      <Tooltip.Trigger
        class="absolute bottom-0 w-full right-0 p-4 text-xl text-left  opacity-100 z-40"
      >
        <p class="text-start">
          {#each (uvideo.title.length > 50 ? `${uvideo.title.slice(0, 49) ?? ""}..` : (uvideo.title ?? "")).split(" ") as titleWord}
            {#if titleWord.startsWith("#")}
              <span class="text-blue-500">{titleWord}{" "}</span>
            {:else}
              {titleWord}{" "}
            {/if}
          {/each}
        </p>
      </Tooltip.Trigger>
      <Tooltip.Content>
        <p>{uvideo.title ?? ""}</p>
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
          class="flex items-center cursor-pointer ml-2 hover:text-white duration-200 justify-center px-1 text-muted-foreground"
        >
          <EllipsisIcon />
        </button>
      </DropdownMenu.Trigger>
      <p class="font-bold">
        {uvideo.author}
      </p>
    </div>
  </button>
  {#if playlistsQuery.data?.playlists}
    <DropdownMenu.Content>
      <DropdownMenu.Sub>
        <DropdownMenu.SubTrigger>
          <PlusIcon size={20} />
          Add to playlist
        </DropdownMenu.SubTrigger>
        <DropdownMenu.SubContent>
          {#each playlistsQuery.data.playlists as playlist}
            <DropdownMenu.Item onclick={() => addToPlaylistMutation.mutate(playlist.playlistId)}>
              {playlist.name}
            </DropdownMenu.Item>
          {/each}
        </DropdownMenu.SubContent>
      </DropdownMenu.Sub>
    </DropdownMenu.Content>
  {/if}
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
