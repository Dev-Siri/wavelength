<script lang="ts">
  import { page } from "$app/state";
  import { ArrowUpRightIcon, PlayIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";

  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import {
    artistExtraResponseSchema,
    artistResponseSchema,
  } from "$lib/utils/validation/artist-response";

  import Image from "$lib/components/Image.svelte";
  import TrackItem from "$lib/components/TrackItem.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Skeleton } from "$lib/components/ui/skeleton";

  function playArtistsSongs(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }

  const artistQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.artist(page.params.browseId),
    queryFn: () => backendClient(`/artists/artist/${page.params.browseId}`, artistResponseSchema),
  }));

  const artistExtraQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.artistExtra(page.params.browseId),
    queryFn: () =>
      backendClient(`/artists/artist/${page.params.browseId}/extra`, artistExtraResponseSchema),
  }));
</script>

<div
  class="h-full w-full bg-black rounded-2xl"
  in:fly={{ y: 20, duration: 100 }}
  out:fly={{ y: 20, duration: 100 }}
>
  {#if artistQuery.isLoading || artistExtraQuery.isLoading}
    <div class="h-full pt-[4%] px-5 flex w-full center">
      <Skeleton class="w-48 h-40 rounded-full" />
      <div class="flex flex-col mt-4 w-full gap-2">
        <Skeleton class="w-4/5 h-5 rounded-full mt-2 mx-4" />
        <Skeleton class="w-2/5 h-5 rounded-full mt-2 mx-4" />
      </div>
    </div>
  {:else if artistQuery.isSuccess}
    {@const artist = artistQuery.data}
    <Dialog.Root>
      <div class="flex flex-col gap-2 h-full relative overflow-scroll scrollbar-hidden pb-[15%]">
        <Dialog.Content class="bg-transparent border-transparent flex items-center justify-center">
          {#if artistExtraQuery.isSuccess}
            <div>
              <Image
                src={artistExtraQuery.data.thumbnail}
                alt="Artist Image"
                height={384}
                width={384}
                draggable
                class="h-96 w-96 rounded-full -mt-3"
              />
            </div>
          {/if}
        </Dialog.Content>
        <div class="flex mb-4 mt-10 ml-4 cursor-pointer select-none">
          {#if artistExtraQuery.isSuccess}
            <Dialog.Trigger class="outline-hidden">
              <Image
                src={artistExtraQuery.data.thumbnail}
                alt="Artist Image"
                height={160}
                width={160}
                draggable
                class="h-40 w-40 rounded-full -mt-3 duration-200"
              />
            </Dialog.Trigger>
          {/if}
          <div class="ml-2 items-center">
            <h1 class="font-black text-6xl">{artist.title}</h1>
            <h2 class="text-xl ml-1">
              {artist.subscriberCount} subscribers
            </h2>
          </div>
        </div>
        <div class="flex gap-2 items-center ml-4">
          {#if artist.songs}
            <Button
              class="rounded-full w-fit py-6"
              onclick={() =>
                artist.songs &&
                playArtistsSongs(
                  artist.songs.contents.map(track => ({
                    ...track,
                    videoType: "track",
                  })),
                )}
            >
              <PlayIcon class="text-primary-foreground" fill="black" />
            </Button>
          {/if}
          <Button
            href="https://music.youtube.com/channel/{page.params.browseId}"
            variant="secondary"
            target="_blank"
            referrerpolicy="no-referrer"
            class="inline-flex gap-1 px-3 items-center"
          >
            View artist on YouTube Music
            <ArrowUpRightIcon />
          </Button>
        </div>
        {#if artist.songs?.titleHeader}
          <p class="px-4 py-2 text-4xl font-bold">{artist.songs.titleHeader}</p>
        {/if}
        <div class="h-full px-2">
          {#if artist.songs}
            {#each artist.songs.contents as song}
              <TrackItem music={{ ...song, duration: "" }} />
            {/each}
          {/if}
        </div>
      </div>
    </Dialog.Root>
  {/if}
</div>
