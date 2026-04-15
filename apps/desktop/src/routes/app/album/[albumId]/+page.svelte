<script lang="ts">
  import { resolve } from "$app/paths";
  import { page } from "$app/state";
  import { ClockIcon, CopyIcon, EllipsisIcon, HashIcon } from "@lucide/svelte";
  import { isTauri } from "@tauri-apps/api/core";
  import { toast } from "svelte-sonner";
  import { fly } from "svelte/transition";

  import type { PlaylistVideoType } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/queue/MusicQueue";

  import { buttonVariants } from "$lib/components/ui/button/button.svelte";
  import { BASE_URL } from "$lib/constants/utils";
  import useAlbumDetailsQuery from "$lib/queries/albumDetails";
  import useIsAlbumLosslessQuery from "$lib/queries/isAlbumLossless";
  import useLiveAlbumCover from "$lib/queries/liveAlbumCover";
  import connectivityStore from "$lib/stores/connectivity.svelte";
  import { getReadableAlbumType } from "$lib/utils/format";

  import AlbumLiveCover from "$lib/components/album/AlbumLiveCover.svelte";
  import AlbumTrackTile from "$lib/components/album/AlbumTrackTile.svelte";
  import Image from "$lib/components/Image.svelte";
  import OpenInDesktopAppOption from "$lib/components/OpenInDesktopAppOption.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import PlaylistThemeGradient from "$lib/components/playlist/PlaylistThemeGradient.svelte";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
  import Spinner from "$lib/components/ui/spinner/spinner.svelte";
  import SaveButton from "./save-button.svelte";

  let pageTitle = $state("Album");

  const albumId = $derived(page.params.albumId ?? "");

  const albumDetailsQuery = $derived(useAlbumDetailsQuery(albumId));

  function copyAlbumLink() {
    navigator.clipboard.writeText(`${BASE_URL}/app/album/${albumId}`);
    toast.info("Copied link to clipboard.");
  }

  $effect(() => {
    if (albumDetailsQuery.isSuccess) {
      pageTitle = `${albumDetailsQuery.data.album.title} by ${albumDetailsQuery.data.album.artist.title}`;
    } else if (albumDetailsQuery.isError) {
      pageTitle = "Album Load Failed.";
    }
  });

  const sortedAlbumTracks = $derived.by(() => {
    if (!albumDetailsQuery.data) return [];

    return albumDetailsQuery.data.album.albumTracks.toSorted(
      (a, b) => a.positionInAlbum - b.positionInAlbum,
    );
  });

  const albumTracks = $derived.by(() => {
    if (!albumDetailsQuery.data) return [];

    return sortedAlbumTracks.map(track => ({
      ...track,
      videoType: "VIDEO_TYPE_TRACK" as PlaylistVideoType,
      album: {
        title: albumDetailsQuery.data.album.title,
        browseId: albumId,
      },
      thumbnail: albumDetailsQuery.data.album.cover,
      artists:
        track.artists[0].title === "VARIOUS_ARTISTS"
          ? [albumDetailsQuery.data.album.artist]
          : track.artists,
    }));
  });

  const albumLiveCoverQuery = $derived(
    useLiveAlbumCover({
      albumId: albumId,
      videoId: albumTracks[0].videoId,
    }),
  );

  const isAlbumLosslessQuery = $derived(useIsAlbumLosslessQuery(albumId));

  const context = $derived({
    type: "album",
    browseId: albumId,
    offlineTracks: albumTracks,
    sourceName: albumDetailsQuery.data?.album.title,
  } satisfies MusicPlaylistContextSource);
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<div
  class="relative flex flex-col h-full w-full bg-secondary/30 rounded-2xl overflow-y-auto pb-[20%] p-4 {isTauri()
    ? 'select-none'
    : ''}"
  in:fly={{ y: 20, duration: 250 }}
  out:fly={{ y: 20, duration: 100 }}
>
  {#if albumDetailsQuery.isSuccess}
    {@const { album } = albumDetailsQuery.data}
    {@const { title, release, cover, artist, totalSongCount, albumType, totalDuration } = album}
    <PlaylistThemeGradient playlistCover={cover} extraSpread />
    <div class="flex gap-4 z-10">
      <div class="relative select-none h-60 w-60 aspect-square overflow-hidden rounded-sm">
        {#if albumLiveCoverQuery.isSuccess && connectivityStore.isOnline && albumLiveCoverQuery.data?.liveAlbumCoverUri}
          <AlbumLiveCover
            height={240}
            width={240}
            liveCoverUri={albumLiveCoverQuery.data.liveAlbumCoverUri}
          />
        {/if}
        {#key cover}
          <Image
            src={cover}
            alt="Playlist Cover"
            class="h-full w-full -z-10 aspect-square"
            height={240}
            width={240}
          />
        {/key}
      </div>
      <div class="flex flex-col justify-center h-52 gap-2">
        <span class="text-sm ml-0.5 select-none">
          {getReadableAlbumType(albumType)} • {release}
          {#if isAlbumLosslessQuery.data?.isLossless}
            • λ Lossless
          {/if}
        </span>
        <h1 class="{title.length > 15 ? 'text-5xl' : 'text-6xl'} font-semibold text-balance">
          {title}
        </h1>
        <div class="flex gap-2 items-center">
          <p class="text-sm">
            {#if artist.browseId === "VARIOUS_ARTISTS"}
              {artist.title}
            {:else}
              <a href={resolve(`/app/artist/${artist.browseId}`)}>
                {artist.title}
              </a>
            {/if}
            <span class="text-muted-foreground">•</span>
            <span class="text-muted-foreground font-normal">
              {totalSongCount}
              {totalSongCount === 1 ? "song" : "songs"},
              {totalDuration}
            </span>
          </p>
        </div>
        <div class="flex items-center gap-2 mt-4">
          <PlaylistPlayOptions tracks={albumTracks} {context} />
          <DropdownMenu.Root>
            <DropdownMenu.Trigger class={buttonVariants({ variant: "ghost", size: "icon" })}>
              <EllipsisIcon />
            </DropdownMenu.Trigger>
            <DropdownMenu.Content>
              <DropdownMenu.Item onclick={copyAlbumLink}>
                <CopyIcon />
                Copy link to Album
              </DropdownMenu.Item>
              <OpenInDesktopAppOption link="wavlen://album/{albumId}" />
            </DropdownMenu.Content>
          </DropdownMenu.Root>
          <SaveButton {albumId} />
        </div>
      </div>
    </div>
    <div class="mt-4">
      <header class="flex items-center select-none text-muted-foreground">
        <section class="flex items-center gap-12 w-2/3 ml-6">
          <HashIcon size={14} />
          <p class="text-sm">Title</p>
        </section>
        <section class="flex justify-center w-1/3">
          <ClockIcon size={14} class="mr-8" />
        </section>
      </header>
      <div class="bg-secondary h-[1px] w-full my-2.5 rounded-full"></div>
      {#each albumTracks as music (music.videoId)}
        <AlbumTrackTile {music} {context} />
      {/each}
    </div>
  {:else if albumDetailsQuery.isError}
    <div class="h-3/4 w-full flex items-center justify-center">
      <p class="text-5xl font-bold text-center text-balance text-red-500">
        An error occurred while loading the album.
      </p>
    </div>
  {:else}
    <div class="h-full w-full flex items-center justify-center">
      <Spinner class="size-28" />
    </div>
  {/if}
</div>
