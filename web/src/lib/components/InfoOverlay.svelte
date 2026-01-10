<script lang="ts">
  import { XIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";

  import type { Snippet } from "svelte";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { punctuatify } from "$lib/utils/format";
  import { backendClient } from "$lib/utils/query-client";
  import { musicVideoPreviewSchema } from "$lib/utils/validation/music-video-preview";

  import MusicVideoPreview from "./MusicVideoPreview.svelte";
  import { Button } from "./ui/button";

  const { children }: { children: Snippet } = $props();

  const musicVideoPreviewQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.musicVideoPreview(
      musicQueueStore.musicPlayingNow?.title ?? "",
      punctuatify(musicQueueStore.musicPlayingNow?.artists.map(artist => artist.title) ?? []),
    ),
    async queryFn() {
      if (
        musicQueueStore.musicPlayingNow &&
        musicQueueStore.musicPlayingNow?.videoType !== "VIDEO_TYPE_UVIDEO"
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

<article class="bg-black relative h-[104%] w-full rounded-t-2xl pr-20 overflow-hidden">
  {#key musicVideoPreviewQuery.data}
    <MusicVideoPreview
      musicVideoId={musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO"
        ? musicQueueStore.musicPlayingNow.videoId
        : (musicVideoPreviewQuery.data?.videoId ?? "")}
    />
  {/key}
  <div class="flex absolute w-full btn-container-gradient rounded-2xl p-3">
    <Button
      class="px-3 rounded-full"
      variant="ghost"
      onclick={() => (musicPlayerStore.visiblePanel = null)}
    >
      <XIcon size={30} />
    </Button>
    {#if musicPlayerStore.visiblePanel === "lyrics"}
      <p class="ml-auto">Lyrics provided by Musixmatch</p>
    {/if}
  </div>
  <div class="mt-14 px-3 overflow-y-auto h-full">
    {@render children?.()}
  </div>
</article>

<style>
  .btn-container-gradient {
    background: linear-gradient(
      to bottom,
      rgba(0, 0, 0, 0.7) 0%,
      rgba(0, 0, 0, 0.5) 40%,
      rgba(0, 0, 0, 0.2) 70%,
      rgba(0, 0, 0, 0) 100%
    );
  }
</style>
