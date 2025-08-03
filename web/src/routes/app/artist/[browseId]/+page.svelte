<script lang="ts">
  import { page } from "$app/state";
  import { ArrowUpRightIcon, PlayIcon } from "@lucide/svelte";
  import { fly } from "svelte/transition";

  import type { PageData } from "./$types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";

  import Image from "$lib/components/Image.svelte";
  // import LinkBeautifier from "$lib/components/LinkBeautifier.svelte";
  import TrackItem from "$lib/components/TrackItem.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Skeleton } from "$lib/components/ui/skeleton";

  const { data }: { data: PageData } = $props();

  function playArtistsSongs(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }
</script>

<div
  class="h-full w-full bg-black rounded-2xl"
  in:fly={{ y: 20, duration: 100 }}
  out:fly={{ y: 20, duration: 100 }}
>
  {#await Promise.all([data.pageData.defaultResponse, data.pageData.extraResponse])}
    <div class="h-full pt-[4%] px-5 flex w-full center">
      <Skeleton class="w-48 h-40 rounded-full" />
      <div class="flex flex-col mt-4 w-full gap-2">
        <Skeleton class="w-4/5 h-5 rounded-full mt-2 mx-4" />
        <Skeleton class="w-2/5 h-5 rounded-full mt-2 mx-4" />
      </div>
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
              <Dialog.Trigger class="outline-hidden">
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
                class="rounded-full w-fit py-6"
                onclick={() =>
                  artistResponse.data.songs &&
                  playArtistsSongs(
                    artistResponse.data.songs.contents.map(track => ({
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
