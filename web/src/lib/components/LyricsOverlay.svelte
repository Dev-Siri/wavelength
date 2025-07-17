<script lang="ts">
  import type { ApiResponse } from "$lib/utils/types";
  import type { LyricsResponse } from "../../routes/api/music/[videoId]/lyrics/types";

  import getClientDB from "$lib/db/client-indexed-db";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import queryClient from "$lib/utils/query-client";
  import LoadingSpinner from "./LoadingSpinner.svelte";

  let lyricsList: HTMLDivElement | null = $state(null);
  let lyrics: LyricsResponse | null = $state([]);
  let duration = $state(0);
  let isLoading = $state(false);
  let hasErrored = $state(false);

  let playerProgress = $derived((musicPlayerStore.musicPlayerProgress / 100) * duration);
  let playerProgressMs = $derived(playerProgress * 1000);
  let currentLyricMs = $derived(lyrics?.find(lyric => lyric.startMs > playerProgressMs) ?? []);

  $effect(() => {
    async function fetchLyrics() {
      if (!musicQueueStore.musicPlayingNow || !musicPlayerStore.musicPlayer) return;

      isLoading = true;
      duration = await musicPlayerStore.musicPlayer.getDuration();

      const db = await getClientDB();
      const storedLyrics = await db.getAllFromIndex(
        "lyrics",
        "by_videoId",
        musicQueueStore.musicPlayingNow.videoId,
      );

      if (storedLyrics.length) {
        lyrics = storedLyrics.toSorted((a, b) => a.order - b.order);
        isLoading = false;
        return;
      }

      try {
        const lyricsResponse = await queryClient<ApiResponse<LyricsResponse>>(
          location.toString(),
          `/api/music/${musicQueueStore.musicPlayingNow.videoId}/lyrics`,
        );

        if (
          lyricsResponse.success &&
          Array.isArray(lyricsResponse.data.length) &&
          lyricsResponse.data.length
        ) {
          lyrics = lyricsResponse.data;

          const tx = db.transaction("lyrics", "readwrite");
          const store = tx.objectStore("lyrics");

          for (const [index, lyric] of lyrics.entries()) {
            const { durMs, startMs, text } = lyric;

            await store.put({
              durMs,
              startMs,
              text,
              videoId: musicQueueStore.musicPlayingNow.videoId,
              lyricId: `l-${musicQueueStore.musicPlayingNow.videoId}-${index}`,
              order: index,
            });
          }

          await tx.done;

          isLoading = false;
          return;
        } else {
          isLoading = false;
          hasErrored = true;
          return;
        }
      } catch {
        isLoading = false;
        hasErrored = true;
      }

      isLoading = false;
      hasErrored = false;
    }

    fetchLyrics();
  });

  $effect(() => {
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
            block: "end",
            inline: "nearest",
          });
        });
    }
  });
</script>

{#if musicQueueStore.musicPlayingNow}
  {#if isLoading}
    <div class="flex flex-col items-center justify-center pt-40 pl-4">
      <LoadingSpinner />
    </div>
  {:else if hasErrored || !lyrics}
    <div class="flex flex-col items-center justify-center pt-52 pl-4">
      <p class="text-5xl font-bold text-center text-balance text-red-500">
        No lyrics available for this track.
      </p>
    </div>
  {:else}
    <div class="flex flex-col pl-4 pt-4 pb-20 gap-10 overflow-auto" bind:this={lyricsList}>
      {#each lyrics as lyric, i}
        <button
          type="button"
          onclick={() => musicPlayerStore.musicPlayer?.seekTo(lyric.startMs / 1000, true)}
          class="font-bold text-start text-3xl cursor-pointer duration-200 hover:text-white {playerProgressMs >
            lyric.startMs && playerProgressMs < lyric.startMs + lyric.durMs
            ? 'text-white'
            : playerProgressMs > lyric.startMs
              ? 'text-gray-300'
              : 'text-gray-500'} {i + 1 === lyrics.length ? 'mb-2' : ''}"
          id="lyric-{lyric.startMs}"
        >
          {lyric.text}
        </button>
      {/each}
    </div>
  {/if}
{/if}
