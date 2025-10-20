<script lang="ts">
  import { lyricsSchema } from "$lib/utils/validation/lyric";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { backendClient } from "$lib/utils/query-client.js";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { createQuery } from "@tanstack/svelte-query";
  import LoadingSpinner from "./LoadingSpinner.svelte";

  let lyricsList: HTMLDivElement | null = $state(null);

  let playerProgressMs = $derived(musicPlayerStore.currentTime * 1000);

  const lyricsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.lyrics(musicQueueStore.musicPlayingNow?.videoId ?? ""),
    queryFn: () =>
      backendClient(
        `/music/track/${musicQueueStore.musicPlayingNow?.videoId}/lyrics`,
        lyricsSchema,
      ),
    gcTime: Infinity,
    staleTime: Infinity,
    refetchOnWindowFocus: false,
  }));

  let currentLyricMs = $derived(
    lyricsQuery.data?.find(lyric => lyric.startMs > playerProgressMs) ?? [],
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
  {#if lyricsQuery.isFetching}
    <div class="flex flex-col items-center justify-center pt-40 pl-4">
      <LoadingSpinner />
    </div>
  {:else if lyricsQuery.isSuccess && lyricsQuery.data.length}
    {@const lyrics = lyricsQuery.data}
    <div class="flex flex-col pl-4 pt-4 pb-20 gap-10 overflow-auto" bind:this={lyricsList}>
      {#each lyrics as lyric, i}
        <button
          type="button"
          onclick={() => musicPlayerStore.seek(lyric.startMs / 1000)}
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
  {:else}
    <div class="flex flex-col items-center justify-center pt-52 pl-4">
      <p class="text-5xl font-bold text-center text-balance text-red-500">
        No lyrics available for this track.
      </p>
    </div>
  {/if}
{/if}
