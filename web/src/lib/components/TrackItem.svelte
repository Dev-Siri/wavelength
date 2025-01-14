<script lang="ts">
  import { MoreHorizontal, Play, Plus } from "lucide-svelte";
  import toast from "svelte-french-toast";

  import type { VideoTypeEnum } from "$lib/db/schema";
  import type { MusicTrack } from "$lib/server/api/interface/types";
  import type { ApiResponse } from "$lib/utils/types";

  import { visiblePanel } from "$lib/stores/music-player";
  import { addToQueue, musicPlayingNow, type QueueableMusic } from "$lib/stores/music-queue";
  import { parseHtmlEntities } from "$lib/utils/format";
  import queryClient from "$lib/utils/query-client";

  import { invalidate } from "$app/navigation";
  import { playlists } from "$lib/stores/playlists";
  import Image from "./Image.svelte";
  import { Button } from "./ui/button";
  import * as DropdownMenu from "./ui/dropdown-menu";
  import * as Tooltip from "./ui/tooltip";

  export let music: MusicTrack & { videoType?: VideoTypeEnum };

  function playSong() {
    const queueableTrack = {
      ...music,
      videoType: music.videoType ?? "track",
    } satisfies QueueableMusic;

    addToQueue(queueableTrack);
    musicPlayingNow.set(queueableTrack);
    $visiblePanel = "playingNow";
  }

  async function addToPlaylist(playlistId: string) {
    const response = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/${playlistId}/tracks`,
      {
        method: "POST",
        body: {
          ...music,
          videoType: "track",
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

<DropdownMenu.Root>
  <div class="flex rounded-md items-center duration-200 p-2 gap-2 hover:bg-muted w-full pr-4">
    <div
      tabindex={0}
      role="button"
      on:click={playSong}
      on:keydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex gap-2 text-start w-full group"
    >
      <div
        class="flex flex-col aspect-square items-center justify-center relative group-hover:rounded-md h-14 w-[70px] duration-200"
      >
        <Play class="absolute hidden group-hover:block z-50" size={18} fill="white" />
        <Image
          src={music.thumbnail}
          alt="Thumbnail"
          class="rounded-md aspect-square object-cover h-full w-full group-hover:opacity-40"
          height={64}
          width={70}
        />
      </div>
      <div class="flex flex-col gap-2 w-full mt-2">
        <p class="leading-none">
          {parseHtmlEntities(
            music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title,
          )}
        </p>
        <p class="text-sm text-muted-foreground leading-none -mt-1">
          {#if music.isExplicit}
            <Tooltip.Root>
              <Tooltip.Trigger>
                <span
                  class="bg-muted-foreground text-primary-foreground px-[5px] font-bold p-0.5 rounded-sm text-xs"
                >
                  E
                </span>
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>Explicit</p>
              </Tooltip.Content>
            </Tooltip.Root>
          {/if}
          {music.author}
        </p>
      </div>
      {#if music.duration}
        <p class="self-center text-sm text-muted-foreground pl-[9%]">
          {music.duration}
        </p>
      {:else}
        <div class="pr-[18%]"></div>
      {/if}
    </div>
    {#if music.duration !== ""}
      <DropdownMenu.Trigger class="h-full">
        <Button variant="ghost" class="flex items-center justify-center px-1 text-muted-foreground">
          <MoreHorizontal />
        </Button>
      </DropdownMenu.Trigger>
    {/if}
  </div>
  <DropdownMenu.Content>
    {#each $playlists as playlist}
      <DropdownMenu.Item
        on:click={() => addToPlaylist(playlist.playlistId)}
        class="flex py-3 gap-2"
      >
        <Plus size={20} /> Add or Remove from Playlist "{playlist.name}"
      </DropdownMenu.Item>
    {/each}
  </DropdownMenu.Content>
</DropdownMenu.Root>
