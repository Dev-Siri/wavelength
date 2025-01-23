<script lang="ts">
  import { X } from "lucide-svelte";

  import type { ApiResponse } from "$lib/utils/types";

  import { visiblePanel } from "$lib/stores/music-player";
  import { musicPlayingNow } from "$lib/stores/music-queue";
  import queryClient from "$lib/utils/query-client";

  import MusicVideoPreview from "./MusicVideoPreview.svelte";
  import { Button } from "./ui/button";

  let musicVideoId = "";

  $: {
    $musicPlayingNow;

    if ($musicPlayingNow && $musicPlayingNow.videoType !== "uvideo")
      fetchMusicVideo($musicPlayingNow);
  }

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
  <div class="fixed w-full btn-container-gradient rounded-2xl p-3">
    <Button
      class="py-6 px-2.5 rounded-full"
      variant="ghost"
      on:click={() => ($visiblePanel = null)}
    >
      <X size={30} />
    </Button>
  </div>
  <div class="mt-14 px-3">
    <slot />
  </div>
</article>

<style lang="postcss">
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
