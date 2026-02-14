<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import type { Snippet } from "svelte";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { punctuatify } from "$lib/utils/format";
  import { backendClient } from "$lib/utils/query-client";
  import { musicVideoPreviewSchema } from "$lib/utils/validation/music-video-preview";

  import MusicVideoPreview from "../MusicVideoPreview.svelte";

  const { children }: { children: Snippet } = $props();

  const musicVideoPreviewQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.musicVideoPreview(
      musicQueueStore.musicPlayingNow?.title ?? "",
      punctuatify(musicQueueStore.musicPlayingNow?.artists.map(artist => artist.title) ?? []),
    ),
    async queryFn() {
      if (
        musicQueueStore.musicPlayingNow &&
        musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO"
      )
        return null;

      return backendClient("/music/music-video-preview", musicVideoPreviewSchema, {
        searchParams: {
          title: musicQueueStore.musicPlayingNow?.title ?? "",
          artist: punctuatify(
            musicQueueStore.musicPlayingNow?.artists.map(artist => artist.title) ?? [],
          ),
        },
      });
    },
  }));
</script>

<article class="relative h-full bg-black w-full rounded-t-2xl pr-20 overflow-hidden">
  {#key musicVideoPreviewQuery.data}
    <MusicVideoPreview
      musicVideoId={musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO"
        ? musicQueueStore.musicPlayingNow.videoId
        : (musicVideoPreviewQuery.data?.videoId ?? "")}
    />
  {/key}
  <div class="mt-14 px-3 overflow-y-auto h-full">
    {@render children?.()}
  </div>
</article>
