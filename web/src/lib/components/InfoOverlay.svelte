<script lang="ts">
  import { X } from "lucide-svelte";

  import type { ApiResponse } from "$lib/utils/types";
  import type { Snippet } from "svelte";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import queryClient from "$lib/utils/query-client";

  import MusicVideoPreview from "./MusicVideoPreview.svelte";
  import { Button } from "./ui/button";

  const { children }: { children: Snippet } = $props();

  let musicVideoId = $state("");

  $effect(() => {
    if (musicQueueStore.musicPlayingNow && musicQueueStore.musicPlayingNow.videoType !== "uvideo")
      fetchMusicVideo(musicQueueStore.musicPlayingNow);
  });

  async function fetchMusicVideo(playingNow: NonNullable<typeof musicQueueStore.musicPlayingNow>) {
    const musicVideoIdResponse = await queryClient<ApiResponse<{ videoId: string }>>(
      location.toString(),
      `/api/music/${playingNow.videoId}/music-video-preview`,
      {
        searchParams: {
          title: playingNow.title,
          artist: playingNow.author,
        },
      },
    );

    if (musicVideoIdResponse.success) musicVideoId = musicVideoIdResponse.data.videoId;
  }
</script>

<article class="bg-black relative h-full w-full rounded-t-2xl pr-20 overflow-hidden">
  {#key musicVideoId}
    <MusicVideoPreview
      musicVideoId={musicQueueStore.musicPlayingNow?.videoType === "uvideo"
        ? musicQueueStore.musicPlayingNow.videoId
        : musicVideoId}
    />
  {/key}
  <div class="flex fixed w-full btn-container-gradient rounded-2xl p-3">
    <Button
      class="px-3 rounded-full"
      variant="ghost"
      onclick={() => (musicPlayerStore.visiblePanel = null)}
    >
      <X size={30} />
    </Button>
    {#if musicPlayerStore.visiblePanel === "lyrics"}
      <p class="ml-auto mr-[23%]">Lyrics provided by Musixmatch</p>
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
