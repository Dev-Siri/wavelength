<script lang="ts">
  import { page } from "$app/state";
  import { ArrowUpRightIcon } from "@lucide/svelte";
  import { fly } from "svelte/transition";

  import useArtistQuery from "$lib/queries/artist";

  import ArtistFollowButton from "$lib/components/artist/ArtistFollowButton.svelte";
  import Image from "$lib/components/Image.svelte";
  import { Button } from "$lib/components/ui/button";
  import Spinner from "$lib/components/ui/spinner/spinner.svelte";
  import * as Tabs from "$lib/components/ui/tabs";
  import About from "./about.svelte";
  import Albums from "./albums.svelte";
  import Home from "./home.svelte";
  import Popular from "./popular.svelte";
  import SinglesAndEps from "./singles-and-eps.svelte";

  let value = $state<"home" | "popular" | "albums" | "singles-and-eps" | "about">("home");

  const artistQuery = $derived(useArtistQuery(page.params.browseId ?? ""));
</script>

<div
  class="h-full w-full bg-black rounded-2xl"
  in:fly={{ y: 20, duration: 250 }}
  out:fly={{ y: 20, duration: 100 }}
>
  {#if artistQuery.isLoading}
    <div class="h-full flex w-full items-center justify-center">
      <Spinner class="size-28" />
    </div>
  {:else if artistQuery.isSuccess}
    {@const { artist } = artistQuery.data}
    <div class="relative h-full select-none overflow-scroll scrollbar-hidden">
      <div class="relative h-[45vh] min-h-[320px] w-full overflow-hidden">
        <Image
          src={artist.thumbnail}
          alt="Artist Image"
          height={1080}
          width={1920}
          draggable="false"
          class="h-full w-full absolute object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-b from-black/10 via-black/50 to-black"></div>
        <div class="relative z-20 px-10 top-1/3">
          <h1 class="text-7xl font-semibold">{artist.title}</h1>
          <div class="flex flex-col gap-2 py-1 ml-1 text-gray-200">
            <p>{artist.audience} subscribers.</p>
          </div>
          <div class="flex gap-2 mt-2">
            <ArtistFollowButton {...artist} />
            <Button
              href="https://music.youtube.com/channel/{artist.browseId}"
              variant="secondary"
              target="_blank"
              referrerpolicy="no-referrer"
              class="inline-flex gap-1 px-3 items-center"
            >
              View artist on YouTube Music
              <ArrowUpRightIcon />
            </Button>
          </div>
        </div>
      </div>
      <div class="flex flex-col gap-2 h-[55vh] z-40">
        <Tabs.Root bind:value>
          <Tabs.List class="mx-2">
            <Tabs.Trigger value="home">Home</Tabs.Trigger>
            <Tabs.Trigger value="popular">Popular</Tabs.Trigger>
            <Tabs.Trigger value="albums">Albums</Tabs.Trigger>
            <Tabs.Trigger value="singles-and-eps">Singles & EPs</Tabs.Trigger>
            <Tabs.Trigger value="about">About</Tabs.Trigger>
          </Tabs.List>
          <Tabs.Content value="home">
            <Home
              {artist}
              showPopular={() => (value = "popular")}
              showAbout={() => (value = "about")}
            />
          </Tabs.Content>
          <Tabs.Content class="px-2" value="popular">
            <Popular {artist} showHome={() => (value = "home")} />
          </Tabs.Content>
          <Tabs.Content class="px-2" value="albums">
            <Albums {artist} />
          </Tabs.Content>
          <Tabs.Content class="px-2" value="singles-and-eps">
            <SinglesAndEps {artist} />
          </Tabs.Content>
          <Tabs.Content class="px-2" value="about">
            <About {artist} />
          </Tabs.Content>
        </Tabs.Root>
      </div>
    </div>
  {/if}
</div>
