<script lang="ts">
  import { X } from "lucide-svelte";

  import type { ApiResponse } from "$lib/utils/types";
  import type { Snippet } from "svelte";

  import { visiblePanel } from "$lib/stores/music-player";
  import { musicPlayingNow } from "$lib/stores/music-queue";
  import queryClient from "$lib/utils/query-client";

  import MusicVideoPreview from "./MusicVideoPreview.svelte";
  import { Button } from "./ui/button";

  const { children }: { children: Snippet } = $props();

  let musicVideoId = $state("");

  $effect(() => {
    if ($musicPlayingNow && $musicPlayingNow.videoType !== "uvideo")
      fetchMusicVideo($musicPlayingNow);
  });

  async function fetchMusicVideo(playingNow: NonNullable<typeof $musicPlayingNow>) {
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

<article
  class="bg-black relative h-full w-full rounded-t-2xl mt-[2%] min-1035:mt-[1%] min-1085:mt-[0.7%] pr-20 overflow-hidden"
>
  {#key musicVideoId}
    <MusicVideoPreview
      musicVideoId={$musicPlayingNow?.videoType === "uvideo"
        ? $musicPlayingNow.videoId
        : musicVideoId}
    />
  {/key}
  <div class="flex fixed w-full btn-container-gradient rounded-2xl p-3">
    <Button class="px-3 rounded-full" variant="ghost" onclick={() => ($visiblePanel = null)}>
      <X size={30} />
    </Button>
    {#if $visiblePanel === "lyrics"}
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
