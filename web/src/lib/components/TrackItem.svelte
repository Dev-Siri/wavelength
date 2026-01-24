<script lang="ts">
  import { EllipsisIcon, HeartIcon, PlayIcon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { VideoType } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { durationify } from "$lib/utils/format";
  import { backendClient } from "$lib/utils/query-client";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  import ArtistLink from "./artist/ArtistLink.svelte";
  import ExplicitIndicator from "./ExplicitIndicator.svelte";
  import Image from "./Image.svelte";
  import PlaylistToggleOptions from "./playlist/PlaylistToggleOptions.svelte";
  import { Button } from "./ui/button";
  import * as DropdownMenu from "./ui/dropdown-menu";

  const {
    music,
    toggle,
    playCount,
  }: {
    music: MusicTrack & { videoType?: VideoType };
    playCount?: string;
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
      videoType: music.videoType ?? "VIDEO_TYPE_TRACK",
    } satisfies QueueableMusic;

    musicQueueStore.musicPlayingNow = queueableTrack;
    musicQueueStore.musicPlaylistContext = [];
    musicPlayerStore.visiblePanel = "playingNow";
  }

  const isTrackLikedQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.isTrackLiked(music.videoId),
    queryFn: () =>
      backendClient(
        `/music/track/likes/${music.videoId}/is-liked`,
        z.object({ isLiked: z.boolean() }),
      ),
  }));

  const likeMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.likeTrack(music.videoId),
    async mutationFn() {
      let duration = music.duration;

      if (duration === "") {
        const fetchedDuration = await backendClient(
          `/music/track/${music.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
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
    class="flex rounded-2xl items-center duration-200 p-1.5 gap-2 hover:bg-muted w-full pr-4 group cursor-pointer"
  >
    <div
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex gap-2 text-start w-full"
    >
      <div
        class="flex flex-col aspect-square items-center justify-center relative group-hover:rounded-lg h-16 w-16 duration-200"
      >
        <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
        {#key music.thumbnail}
          <Image
            src={music.thumbnail}
            alt="Thumbnail"
            class="rounded-2xl aspect-square object-cover h-full w-full group-hover:opacity-40"
            height={64}
            width={70}
          />
        {/key}
      </div>
      <div class="flex flex-col gap-2 w-full mt-2">
        <p class="leading-none text-md">
          {music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title}
        </p>
        <p class="text-sm text-muted-foreground leading-none -mt-1">
          {#if music.isExplicit}
            <ExplicitIndicator />
          {/if}
          {#each music.artists as artist}
            <ArtistLink
              {...artist}
              isUVideo={music.videoType === "VIDEO_TYPE_UVIDEO"}
              trailingComma={music.artists.length - 1 !== music.artists.indexOf(artist)}
            />
            {#if playCount}
              • {playCount}
            {/if}
          {/each}
        </p>
      </div>
      {#if music.duration}
        <p class="self-center text-sm text-muted-foreground pl-[9%]">
          {durationify(Number(music.duration))}
        </p>
      {:else}
        <div class="pr-[18%]"></div>
      {/if}
    </div>
    <Button
      variant="ghost"
      class="flex items-center p-0 mx-4 justify-center text-muted-foreground {isTrackLikedQuery.data
        ?.isLiked
        ? 'text-red-500'
        : ''}"
      onclick={() => likeMutation.mutate()}
    >
      {#if isTrackLikedQuery.data?.isLiked}
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
