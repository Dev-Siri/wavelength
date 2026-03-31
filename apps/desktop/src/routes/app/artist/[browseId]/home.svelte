<script lang="ts">
  import { CheckIcon, ChevronDownIcon } from "@lucide/svelte";
  import { slide } from "svelte/transition";

  import type { CarouselOptions } from "$lib/components/ui/carousel/context";
  import type { Artist } from "$lib/schemas/artist";
  import type { PlaylistVideoType } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/MusicQueue.svelte";

  import AlbumCard from "$lib/components/album/AlbumCard.svelte";
  import Image from "$lib/components/Image.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import Track from "$lib/components/track/Track.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import * as Carousel from "$lib/components/ui/carousel";

  const {
    artist,
    showPopular,
    showAbout,
  }: { artist: Artist; showPopular: () => void; showAbout: () => void } = $props();

  let discographyFilter = $state<"all" | "releases" | "singles" | "eps">("all");

  const isFilteredAll = $derived(discographyFilter === "all");
  const isFilteredReleases = $derived(discographyFilter === "releases");
  const isFilteredSingles = $derived(discographyFilter === "singles");
  const isFilteredEps = $derived(discographyFilter === "eps");

  const artistTopSongsQueueable = $derived(
    artist.topSongs.map(track => ({
      ...track,
      videoType: "VIDEO_TYPE_TRACK" as PlaylistVideoType,
    })),
  );

  const context = $derived({
    type: "artistTopSongs",
    browseId: artist.browseId,
    sourceName: artist.title,
  } satisfies MusicPlaylistContextSource);

  const filteredSinglesOrEps = $derived.by(() => {
    if (isFilteredAll) return artist.singlesAndEps;

    if (isFilteredSingles)
      return artist.singlesAndEps.filter(album => album.albumType === "ALBUM_TYPE_SINGLE");

    if (isFilteredEps)
      return artist.singlesAndEps.filter(album => album.albumType === "ALBUM_TYPE_EP");

    return [];
  });

  const normalizedDescription = $derived.by(() => {
    const wikipediaLine = artist.description?.indexOf("From Wikipedia");
    if (!wikipediaLine) return "";

    return artist.description?.slice(0, wikipediaLine) ?? "";
  });

  const discographyCarouselOptions = {
    loop: true,
    dragFree: true,
    containScroll: "trimSnaps",
  } satisfies CarouselOptions;
</script>

<div class="h-full w-full overflow-x-hidden pb-[20%]">
  <div class="flex items-center gap-2 justify-between px-4 mb-2">
    <span class="text-xl font-semibold">Most popular from {artist.title}</span>
    <PlaylistPlayOptions {context} tracks={artistTopSongsQueueable} />
  </div>
  <div id="popular-music-sliced-5" class="px-2">
    {#each artist.topSongs.slice(0, 6) as music (music.videoId)}
      <Track {context} {music} playCount={music.playCount} toggle={{ type: "add" }} />
    {/each}
    <div class="w-full flex justify-center">
      <Button variant="ghost" onclick={showPopular}>
        <ChevronDownIcon />
      </Button>
    </div>
  </div>
  <div class="px-2">
    <div class="flex items-center gap-2 justify-between mt-4">
      <span class="text-xl font-semibold">Explore {artist.title}'s discography.</span>
    </div>
    <div id="discography-filters" class="mb-4 mt-2">
      <Button
        size="sm"
        variant={isFilteredAll ? "default" : "secondary"}
        onclick={() => (discographyFilter = "all")}
      >
        {#if isFilteredAll}
          <CheckIcon />
        {/if}
        All
      </Button>
      <Button
        size="sm"
        variant={isFilteredReleases ? "default" : "secondary"}
        onclick={() => (discographyFilter = "releases")}
      >
        {#if isFilteredReleases}
          <CheckIcon />
        {/if}
        Releases
      </Button>
      <Button
        size="sm"
        variant={isFilteredSingles ? "default" : "secondary"}
        onclick={() => (discographyFilter = "singles")}
      >
        {#if isFilteredSingles}
          <CheckIcon />
        {/if}
        Singles
      </Button>
      <Button
        size="sm"
        variant={isFilteredEps ? "default" : "secondary"}
        onclick={() => (discographyFilter = "eps")}
      >
        {#if isFilteredEps}
          <CheckIcon />
        {/if}
        EPs
      </Button>
    </div>
  </div>
  {#if !isFilteredEps && !isFilteredSingles}
    <div in:slide={{ axis: "x" }} out:slide={{ axis: "x" }}>
      <Carousel.Root opts={discographyCarouselOptions}>
        <Carousel.Content class="mb-2">
          {#each artist.albums as album (album.albumId)}
            <Carousel.Item class="basis-1/4">
              <AlbumCard album={{ ...album, artist }} />
            </Carousel.Item>
          {/each}
        </Carousel.Content>
        <Carousel.Previous />
        <Carousel.Next />
      </Carousel.Root>
    </div>
  {/if}
  {#if !isFilteredReleases}
    <div in:slide={{ axis: "x" }} out:slide={{ axis: "x" }}>
      <Carousel.Root class="mt-4" opts={discographyCarouselOptions}>
        <Carousel.Content class="mb-2">
          {#each filteredSinglesOrEps as album (album.albumId)}
            <Carousel.Item class="basis-1/4">
              <AlbumCard album={{ ...album, artist }} />
            </Carousel.Item>
          {/each}
        </Carousel.Content>
        <Carousel.Previous />
        <Carousel.Next />
      </Carousel.Root>
    </div>
  {/if}
  <button
    type="button"
    onclick={showAbout}
    class="px-4 cursor-pointer w-full text-start transition-all hover:opacity-90"
  >
    <div class="relative h-[500px] w-full rounded-xl overflow-hidden mt-20">
      <div class="absolute inset-0 flex flex-col gap-4 justify-end h-full p-12 z-20">
        <h1 class="text-6xl font-semibold">{artist.title}</h1>
        <p class="leading-relaxed text-lg line-clamp-4">{normalizedDescription}</p>
      </div>
      <Image
        src={artist.thumbnail}
        alt="{artist.title}'s Picture"
        height={500}
        width={500}
        draggable="false"
        class="h-full w-full object-cover brightness-50"
      />
    </div>
  </button>
</div>
