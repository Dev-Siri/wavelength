<script lang="ts">
  import { EllipsisIcon, HeartIcon, PlayIcon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { VideoType } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { backendClient } from "$lib/utils/query-client";

  import toast from "svelte-french-toast";
  import z from "zod";
  import ExplicitIndicator from "./ExplicitIndicator.svelte";
  import Image from "./Image.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import { Button } from "./ui/button";
  import * as DropdownMenu from "./ui/dropdown-menu";

  const {
    music,
    toggle,
  }: {
    music: MusicTrack & { videoType?: VideoType };
    toggle:
      | { type: "add" }
      | {
          type: "remove";
          from: Playlist;
        };
  } = $props();

  const queryClient = useQueryClient();

  function playSong() {
    const queueableTrack = {
      ...music,
      videoType: music.videoType ?? "track",
    } satisfies QueueableMusic;

    musicQueueStore.addToQueue(queueableTrack);
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }

  const isTrackLikedQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.isTrackLiked(music.videoId),
    queryFn: () => backendClient(`/music/track/likes/${music.videoId}/is-liked`, z.boolean()),
  }));

  const likeMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.likeTrack(music.videoId),
    async mutationFn() {
      let duration = music.duration;

      if (duration === "") {
        const fetchedDuration = await backendClient(
          `/music/track/${music.videoId}/duration`,
          z.number(),
        );
        duration = fetchedDuration.toString();
      }

      return backendClient("/music/track/likes", z.string(), {
        method: "PATCH",
        body: {
          ...music,
          duration,
          videoType: "track",
        },
      });
    },
    onError: () => toast.error("Failed to like track."),
    onSuccess() {
      isTrackLikedQuery.refetch();
      queryClient.invalidateQueries({
        queryKey: [...svelteQueryKeys.likeCount, ...svelteQueryKeys.likes],
      });
    },
  }));
</script>

<DropdownMenu.Root>
  <div
    class="flex rounded-lg items-center duration-200 p-1.5 gap-2 hover:bg-muted w-full pr-4 group cursor-pointer"
  >
    <div
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex gap-2 text-start w-full"
    >
      <div
        class="flex flex-col aspect-square items-center justify-center relative group-hover:rounded-lg h-12 w-12 duration-200"
      >
        <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
        {#key music.thumbnail}
          <Image
            src={music.thumbnail}
            alt="Thumbnail"
            class="rounded-md aspect-square object-cover h-full w-full group-hover:opacity-40"
            height={64}
            width={70}
          />
        {/key}
      </div>
      <div class="flex flex-col gap-2 w-full mt-2">
        <p class="leading-none text-sm">
          {music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title}
        </p>
        <p class="text-sm text-muted-foreground leading-none -mt-1">
          {#if music.isExplicit}
            <ExplicitIndicator />
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
    <Button
      variant="ghost"
      class="flex items-center p-0 mx-4 justify-center text-muted-foreground {isTrackLikedQuery.data
        ? 'text-red-500'
        : ''}"
      onclick={() => likeMutation.mutate()}
    >
      {#if isTrackLikedQuery.data}
        <HeartIcon fill="red" />
      {:else}
        <HeartIcon />
      {/if}
    </Button>
    <DropdownMenu.Trigger class="h-full">
      <Button variant="ghost" class="flex items-center justify-center px-1 text-muted-foreground">
        <EllipsisIcon />
      </Button>
    </DropdownMenu.Trigger>
  </div>
  <DropdownMenu.Content>
    <PlaylistToggleOptions {music} {toggle} />
  </DropdownMenu.Content>
</DropdownMenu.Root>
