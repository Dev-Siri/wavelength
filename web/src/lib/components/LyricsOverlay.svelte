<script lang="ts">
  import { onMount } from "svelte";

  import type { ApiResponse } from "$lib/utils/types";
  import type { LyricsResponse } from "../../routes/api/music/[videoId]/lyrics/types";

  import { musicPlayer, musicPlayerProgress } from "$lib/stores/music-player";
  import { musicPlayingNow } from "$lib/stores/music-queue";
  import queryClient from "$lib/utils/query-client";

  let lyricsList: HTMLDivElement;
  let lyrics: LyricsResponse | null = [];
  let duration = 0;
  let isLoading = false;
  let hasErrored = false;

  $: playerProgress = ($musicPlayerProgress / 100) * duration;
  $: playerProgressMs = playerProgress * 1000;
  $: currentLyricMs = lyrics?.find(lyric => lyric.startMs > playerProgressMs) ?? [];

  onMount(() => {
    async function fetchLyrics() {
      if (!$musicPlayingNow || !$musicPlayer) return;

      isLoading = true;

      duration = await $musicPlayer.getDuration();

      const storedLyrics = sessionStorage.getItem(`${$musicPlayingNow.videoId}-l`);

      if (storedLyrics) {
        const parsedStoredLyrics = JSON.parse(storedLyrics);

        if (!Array.isArray(parsedStoredLyrics)) {
          isLoading = false;
          hasErrored = true;
          return;
        }

        lyrics = parsedStoredLyrics;

        isLoading = false;
        return;
      }

      try {
        const lyricsResponse = await queryClient<ApiResponse<LyricsResponse>>(
          location.toString(),
          `/api/music/${$musicPlayingNow.videoId}/lyrics`,
        );
        if (lyricsResponse.success) {
          lyrics = lyricsResponse.data;

          sessionStorage.setItem(`${$musicPlayingNow.videoId}-l`, JSON.stringify(lyrics));
          isLoading = false;
          return;
        }
      } catch {
        isLoading = false;
        hasErrored = true;
      }

      isLoading = false;
      hasErrored = true;
    }

    fetchLyrics();
  });

  $: {
    if (
      typeof window !== "undefined" &&
      lyricsList &&
      currentLyricMs &&
      "startMs" in currentLyricMs
    ) {
      const lyricElement = document.getElementById(`lyric-${currentLyricMs.startMs}`);
      if (lyricElement)
        requestAnimationFrame(() => {
          lyricElement.scrollIntoView({
            behavior: "smooth",
            block: "center",
            inline: "nearest",
          });
        });
    }
  }
</script>

{#if $musicPlayingNow}
  {#if isLoading}
    <div class="flex flex-col items-center justify-center pt-52 pl-4">
      <p class="text-5xl font-bold">Loading Lyrics...</p>
    </div>
  {:else if hasErrored || !lyrics}
    <div class="flex flex-col items-center justify-center pt-52 pl-4">
      <p class="text-5xl font-bold text-center text-balance text-red-500">
        No lyrics available for this track.
      </p>
    </div>
  {:else}
    <div
      class="flex flex-col pl-4 pt-4 gap-10 h-[470px] scrollbar-hidden overflow-auto"
      bind:this={lyricsList}
    >
      {#each lyrics as lyric}
        <button
          type="button"
          on:click={() => $musicPlayer?.seekTo(lyric.startMs / 1000, true)}
          class="font-bold text-start text-3xl cursor-pointer duration-200 hover:text-white {playerProgressMs >
            lyric.startMs && playerProgressMs < lyric.startMs + lyric.durMs
            ? 'text-white'
            : playerProgressMs > lyric.startMs
              ? 'text-gray-300'
              : 'text-gray-500'}"
          id="lyric-{lyric.startMs}"
        >
          {lyric.text}
        </button>
      {/each}
      <p class="cursor-default mb-4">Lyrics provided by Musixmatch.</p>
    </div>
  {/if}
{/if}
