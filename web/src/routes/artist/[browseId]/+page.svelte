<script lang="ts">
  import { page } from "$app/stores";
  import { ArrowUpRight, Play } from "lucide-svelte";
  import { fly } from "svelte/transition";

  import Image from "$lib/components/Image.svelte";
  // import LinkBeautifier from "$lib/components/LinkBeautifier.svelte";
  import TrackItem from "$lib/components/TrackItem.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Skeleton } from "$lib/components/ui/skeleton";

  import { playMusic } from "$lib/stores/music-player";
  import {
    addToQueue,
    musicPlayingNow,
    musicQueue,
    type QueueableMusic,
  } from "$lib/stores/music-queue";

  export let data;

  function playArtistsSongs(songs: QueueableMusic[]) {
    musicQueue.set([]);
    addToQueue(...songs);
    musicPlayingNow.set(songs[0]);
    playMusic();
  }
</script>

<div
  class="h-full w-full bg-black mt-2 rounded-2xl"
  in:fly={{ y: 20, duration: 100 }}
  out:fly={{ y: 20, duration: 100 }}
>
  {#await Promise.all([data.pageData.defaultResponse, data.pageData.extraResponse])}
    <div class="flex flex-col gap-2 h-full">
      <Skeleton class="h-72 w-full rounded-t-2xl" />
      <Skeleton class="w-4/5 h-5 rounded-full mt-2 mx-4" />
      <Skeleton class="w-2/5 h-5 rounded-full mt-2 mx-4" />
    </div>
  {:then [artistResponse, extraResponse]}
    {#if artistResponse.success}
      <Dialog.Root>
        <div class="flex flex-col gap-2 h-full relative overflow-scroll scrollbar-hidden pb-[15%]">
          <Dialog.Content
            class="bg-transparent border-transparent flex items-center justify-center"
          >
            {#if extraResponse.success}
              <div>
                <Image
                  src={extraResponse.data.items?.[0].snippet?.thumbnails?.high?.url ?? ""}
                  alt="Artist Image"
                  height={384}
                  width={384}
                  draggable
                  class="h-96 w-96 rounded-full -mt-3"
                />
              </div>
            {/if}
          </Dialog.Content>
          <div class="flex mb-4 mt-10 ml-4 select-none">
            {#if extraResponse.success}
              <Dialog.Trigger class="outline-none">
                <Image
                  src={extraResponse.data.items?.[0].snippet?.thumbnails?.high?.url ?? ""}
                  alt="Artist Image"
                  height={160}
                  width={160}
                  draggable
                  class="h-40 w-40 rounded-full -mt-3 duration-200"
                />
              </Dialog.Trigger>
            {/if}
            <div class="ml-2 items-center">
              <h1 class="font-black text-6xl">{artistResponse.data.title ?? "Not found."}</h1>
              <h2 class="text-xl ml-1 {!artistResponse.data.subscriberCount && 'mt-1'}">
                {artistResponse.data.subscriberCount
                  ? `${artistResponse.data.subscriberCount} subscribers`
                  : "We don't have much information about this artist, try searching on YT Music."}
              </h2>
            </div>
          </div>
          <!-- <p class="px-4 text-xs line">
            <LinkBeautifier text={artistResponse.data.description} />
          </p> -->
          <div class="flex gap-2 items-center ml-4">
            {#if artistResponse.data.songs}
              <Button
                class="rounded-full w-fit py-7"
                on:click={() =>
                  artistResponse.data.songs &&
                  playArtistsSongs(
                    artistResponse.data.songs.contents.map(track => ({
                      ...track,
                      videoType: "track",
                    })),
                  )}
              >
                <Play class="text-primary-foreground" fill="black" />
              </Button>
            {/if}
            <Button
              href="https://music.youtube.com/channel/{$page.params.browseId}"
              variant="secondary"
              target="_blank"
              referrerpolicy="no-referrer"
              class="inline-flex gap-1 px-2 items-center"
            >
              View artist on YouTube Music
              <ArrowUpRight />
            </Button>
          </div>
          {#if artistResponse.data?.songs?.titleHeader}
            <p class="px-4 py-2 text-4xl font-bold">{artistResponse.data.songs.titleHeader}</p>
          {/if}
          <div class="h-full px-2">
            {#if artistResponse.data.songs}
              {#each artistResponse.data.songs.contents as song}
                <TrackItem music={{ ...song, duration: "" }} />
              {/each}
            {/if}
          </div>
        </div>
      </Dialog.Root>
    {/if}
  {/await}
</div>
