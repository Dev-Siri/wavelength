<script lang="ts">
  import { lyricsSchema } from "$lib/utils/validation/lyric";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { backendClient } from "$lib/utils/query-client.js";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { createQuery } from "@tanstack/svelte-query";
  import { get, set } from "idb-keyval";
  import z from "zod";
  import LoadingSpinner from "./LoadingSpinner.svelte";

  let lyricsList: HTMLDivElement | null = $state(null);

  let playerProgress = $derived((musicPlayerStore.progress / 100) * musicPlayerStore.duration);

  const lyricsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.lyrics(musicQueueStore.musicPlayingNow?.videoId ?? ""),
    async queryFn() {
      const cachedLyrics = await get(`lyrics-${musicQueueStore.musicPlayingNow?.videoId}`);

      if (!cachedLyrics) {
        const lyrics = await backendClient(
          `/music/track/${musicQueueStore.musicPlayingNow?.videoId}/lyrics`,
          lyricsSchema,
        );

        await set(`lyrics-${musicQueueStore.musicPlayingNow?.videoId}`, JSON.stringify(lyrics));
        return lyrics;
      }

      const parsedLyricsString = z.string().parse(cachedLyrics);
      const lyrics = lyricsSchema.parse(parsedLyricsString);

      return lyrics;
    },
    gcTime: Infinity,
    staleTime: Infinity,
    refetchOnWindowFocus: false,
  }));

  let currentLyricMs = $derived(
    lyricsQuery.data?.find(lyric => lyric.startMs > playerProgress) ?? [],
  );

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
  {#if lyricsQuery.isLoading}
    <div class="flex flex-col items-center justify-center pt-40 pl-4">
      <LoadingSpinner />
    </div>
  {:else if lyricsQuery.isSuccess && lyricsQuery.data.length}
    {@const lyrics = lyricsQuery.data}
    <div class="flex flex-col pl-4 pt-4 pb-20 gap-10 overflow-auto" bind:this={lyricsList}>
      {#each lyrics as lyric, i}
        <button
          type="button"
          onclick={() => musicPlayerStore.musicPlayer?.seekTo(lyric.startMs / 1000, true)}
          class="font-bold text-start text-3xl cursor-pointer duration-200 hover:text-white {playerProgress >
            lyric.startMs && playerProgress < lyric.startMs + lyric.durMs
            ? 'text-white'
            : playerProgress > lyric.startMs
              ? 'text-gray-300'
              : 'text-gray-500'} {i + 1 === lyrics.length ? 'mb-2' : ''}"
          id="lyric-{lyric.startMs}"
        >
          {lyric.text}
        </button>
      {/each}
    </div>
  {:else}
    <div class="flex flex-col items-center justify-center pt-52 pl-4">
      <p class="text-5xl font-bold text-center text-balance text-red-500">
        No lyrics available for this track.
      </p>
    </div>
  {/if}
{/if}
