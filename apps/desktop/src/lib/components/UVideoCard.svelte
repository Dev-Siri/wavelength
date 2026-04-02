<script lang="ts">
  import { PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import type { YouTubeVideo } from "$lib/schemas/youtube-video";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { musicTrackDurationSchema } from "$lib/schemas/track-length";
  import userStore from "$lib/stores/user.svelte";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";
  import { backendClient, reportErrorToBackend } from "$lib/utils/query-client.js";

  import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import useUserPlaylistsQuery from "$lib/queries/userPlaylists";
  import Image from "./Image.svelte";

  const { uvideo }: { uvideo: YouTubeVideo } = $props();

  const queryClient = useQueryClient();
  const userPlaylistsQuery = $derived(useUserPlaylistsQuery(userStore.user?.email ?? ""));

  async function playYtVideo() {
    try {
      await musicPlayer.load({
        ...uvideo,
        artists: [
          {
            title: uvideo.author,
            browseId: uvideo.authorChannelId,
          },
        ],
        videoType: "VIDEO_TYPE_UVIDEO",
      });
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "UVideoCard: playYtVideo()",
      });
    }
  }

  const addToPlaylistMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.addUVideoToPlaylist,
    onError: () => toast.error("Failed to update playlist."),
    onSuccess(data: string, playlistId: string) {
      toast.success(data);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlistTrackLength(playlistId) });
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlistTrack(playlistId) });
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
          thumbnail: uvideo.thumbnail,
          videoType: "uvideo",
        },
      });
    },
  }));
</script>

<DropdownMenu.Root>
  <div
    role="button"
    class="bg-[#212121] flex flex-col rounded-md pb-3"
    tabindex="0"
    onclick={playYtVideo}
    onkeydown={playYtVideo}
  >
    <div class="relative rounded-md group">
      {#key uvideo.thumbnail}
        <Image
          src={uvideo.thumbnail}
          height={300}
          width={360}
          alt="YouTube Video Thumbnail"
          class="rounded-md h-full w-full object-cover opacity-75 group-hover:opacity-100 duration-200"
        />
      {/key}
    </div>
    {#if userPlaylistsQuery.data?.playlists}
      <DropdownMenu.Content>
        <DropdownMenu.Sub>
          <DropdownMenu.SubTrigger>
            <PlusIcon size={20} />
            Add to playlist
          </DropdownMenu.SubTrigger>
          <DropdownMenu.SubContent>
            {#each userPlaylistsQuery.data.playlists as playlist (playlist.playlistId)}
              <DropdownMenu.Item onclick={() => addToPlaylistMutation.mutate(playlist.playlistId)}>
                {playlist.name}
              </DropdownMenu.Item>
            {/each}
          </DropdownMenu.SubContent>
        </DropdownMenu.Sub>
      </DropdownMenu.Content>
    {/if}
    <Tooltip.Root>
      <Tooltip.Trigger class="w-full mt-2 px-3 text-sm font-semibold text-left">
        <p class="text-start">
          {uvideo.title}
        </p>
      </Tooltip.Trigger>
      <Tooltip.Content>
        <p>{uvideo.title ?? ""}</p>
      </Tooltip.Content>
    </Tooltip.Root>
    <p class="font-semibold text-xs px-3 text-muted-foreground">
      {uvideo.author}
    </p>
    <DropdownMenu.Trigger
      onclick={e => e.stopPropagation()}
      class="flex ml-auto items-center gap-1 cursor-pointer mr-3 mt-auto hover:text-white duration-200 justify-center px-1 text-muted-foreground"
    >
      <PlusIcon size={14} class="font-bold" /> Add
    </DropdownMenu.Trigger>
  </div>
</DropdownMenu.Root>
