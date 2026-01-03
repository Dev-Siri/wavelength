<script lang="ts">
  import { page } from "$app/state";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";
  import { backendClient } from "$lib/utils/query-client";
  import { albumDetailsSchema } from "$lib/utils/validation/albums";

  import AlbumTrackTile from "$lib/components/AlbumTrackTile.svelte";
  import ExplicitIndicator from "$lib/components/ExplicitIndicator.svelte";
  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import { PlayIcon } from "@lucide/svelte";

  let pageTitle = $state("Album");

  const albumDetailsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.album(page.params.albumId ?? ""),
    queryFn: () => backendClient(`/albums/album/${page.params.albumId}`, albumDetailsSchema),
  }));

  $effect(() => {
    if (albumDetailsQuery.isSuccess) {
      pageTitle = `${albumDetailsQuery.data.title} by ${albumDetailsQuery.data.albumAuthor}`;
    } else {
      pageTitle = "Album Load Failed.";
    }
  });

  function playAlbum(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<div
  class="flex flex-col h-full w-full bg-black rounded-2xl overflow-y-auto pb-[16%]"
  in:fly={{ y: 20, duration: 250 }}
  out:fly={{ y: 20, duration: 100 }}
>
  {#if albumDetailsQuery.isSuccess}
    {@const album = albumDetailsQuery.data}
    <article class="flex h-full w-full">
      <div class="h-full w-1/2 flex flex-col justify-center items-center">
        {#key album.albumCover}
          <Image
            src={album.albumCover}
            alt="Album Cover"
            height={300}
            width={300}
            class="rounded-2xl"
          />
        {/key}
        <h1 class="text-2xl pt-4">{album.title}</h1>
        <div class="flex gap-12">
          <p class="text-md">
            {#if album.isExplicit}
              <ExplicitIndicator />
            {/if}
            <span class="text-muted-foreground">{album.albumType} By</span>
            {album.albumAuthor}
            <span class="text-muted-foreground">•</span>
            {album.albumRelease}
          </p>
          <p class="text-md">
            {album.albumTotalSong}, {album.albumTotalDuration}
          </p>
        </div>
        <Button
          class="mt-4"
          onclick={() =>
            playAlbum(
              album.results.map(track => ({
                ...track,
                videoType: "VIDEO_TYPE_TRACK",
                thumbnail: album.albumCover,
              })),
            )}
        >
          <PlayIcon fill="1" />
          Play Album
        </Button>
      </div>
      <div class="h-full w-1/2 py-20 px-4 overflow-auto border-l border-l-muted">
        {#each album.results as albumTrack}
          <AlbumTrackTile
            music={{
              ...albumTrack,
              thumbnail: album.albumCover,
            }}
            toggle={{ type: "add" }}
          />
        {/each}
      </div>
    </article>
  {:else if albumDetailsQuery.isError}
    <div class="h-3/4 w-full flex items-center justify-center">
      <p class="text-5xl font-bold text-center text-balance text-red-500">
        An error occurred while loading the album.
      </p>
    </div>
  {:else}
    <div class="h-full w-full flex items-center justify-center">
      <LoadingSpinner />
    </div>
  {/if}
</div>
