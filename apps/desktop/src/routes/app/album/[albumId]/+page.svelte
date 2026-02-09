<script lang="ts">
  import { page } from "$app/state";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { getReadableAlbumType } from "$lib/utils/format";
  import { backendClient } from "$lib/utils/query-client";
  import { albumDetailsSchema } from "$lib/utils/validation/albums";

  import AlbumTrackTile from "$lib/components/album/AlbumTrackTile.svelte";
  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import Button from "$lib/components/ui/button/button.svelte";

  let pageTitle = $state("Album");

  const albumDetailsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.album(page.params.albumId ?? ""),
    queryFn: () => backendClient(`/albums/album/${page.params.albumId}`, albumDetailsSchema),
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    refetchOnReconnect: false,
  }));

  $effect(() => {
    if (albumDetailsQuery.isSuccess) {
      pageTitle = `${albumDetailsQuery.data.album.title} by ${albumDetailsQuery.data.album.artist.title}`;
    } else if (albumDetailsQuery.isError) {
      pageTitle = "Album Load Failed.";
    }
  });
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
    {@const { album } = albumDetailsQuery.data}
    <article class="flex h-full w-full">
      <div class="h-full w-1/2 flex flex-col justify-center items-center">
        {#key album.cover}
          <Image src={album.cover} alt="Album Cover" height={300} width={300} class="rounded-2xl" />
        {/key}
        <h1 class="text-2xl pt-4 w-2/3 text-center">{album.title}</h1>
        <div class="text-center mb-4">
          <p class="text-sm">
            <span class="text-muted-foreground">{getReadableAlbumType(album.albumType)} by</span>
            <Button variant="link" href="/app/artist/{album.artist.browseId}" class="px-0">
              {album.artist.title}
            </Button>
            <span class="text-muted-foreground">•</span>
            {album.release}
          </p>
          <p class="text-sm">
            {album.totalSongCount}
            {album.totalSongCount === 1 ? "song" : "songs"}, {album.totalDuration}
          </p>
        </div>
        <PlaylistPlayOptions
          tracks={album.albumTracks.map(track => ({
            ...track,
            videoType: "VIDEO_TYPE_TRACK",
            album: {
              title: album.title,
              browseId: page.params.albumId ?? "",
            },
            thumbnail: album.cover,
            artists: [album.artist],
          }))}
        />
      </div>
      <div class="h-full w-1/2 py-20 px-4 overflow-auto border-l border-l-muted">
        {#each album.albumTracks.sort((a, b) => a.positionInAlbum - b.positionInAlbum) as albumTrack}
          <AlbumTrackTile
            music={{
              ...albumTrack,
              album: {
                title: album.title,
                browseId: page.params.albumId ?? "",
              },
              thumbnail: album.cover,
              artists: [album.artist],
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
