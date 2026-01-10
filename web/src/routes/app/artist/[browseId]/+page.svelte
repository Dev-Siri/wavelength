<script lang="ts">
  import { page } from "$app/state";
  import { ArrowUpRightIcon, PlayIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";

  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { artistResponseSchema } from "$lib/utils/validation/artist-response";

  import AlbumTile from "$lib/components/AlbumTile.svelte";
  import ArtistFollowButton from "$lib/components/ArtistFollowButton.svelte";
  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import TrackItem from "$lib/components/TrackItem.svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";

  function playArtistsSongs(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }

  const artistQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.artist(page.params.browseId ?? ""),
    queryFn: () => backendClient(`/artists/artist/${page.params.browseId}`, artistResponseSchema),
  }));
</script>

<Dialog.Root>
  <div
    class="h-full w-full bg-black rounded-2xl pb-[15%]"
    in:fly={{ y: 20, duration: 250 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    {#if artistQuery.isLoading}
      <div class="h-full flex w-full items-center justify-center">
        <LoadingSpinner />
      </div>
    {:else if artistQuery.isSuccess}
      {@const { artist } = artistQuery.data}
      {@const description = artist.description ?? ""}
      <Dialog.Content>
        {description}
      </Dialog.Content>
      <div class="relative h-full overflow-scroll scrollbar-hidden">
        <div class="relative h-[45vh] min-h-[320px] w-full overflow-hidden">
          <Image
            src={artist.thumbnail}
            alt="Artist Image"
            height={1080}
            width={1920}
            draggable
            class="h-full w-full absolute object-cover"
          />
          <div class="absolute inset-0 bg-gradient-to-b from-black/10 via-black/50 to-black"></div>
          <div class="relative z-20 px-10 top-1/3">
            <h1 class="text-5xl">{artist.title}</h1>
            <div class="flex flex-col gap-2 py-1 ml-1 text-gray-200">
              <p>{artist.audience} subscribers.</p>
              <Dialog.Trigger class="text-start cursor-pointer">
                <p class="text-sm w-1/2">
                  {description ? `${description.slice(0, 140)}...` : description}
                </p>
              </Dialog.Trigger>
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
        <div class="flex flex-col gap-2 h-full px-10 z-40 mt-6">
          <section>
            {#if artist.topSongs.length}
              <div class="flex items-center justify-between">
                <h4 class="p-2 mb-2 text-3xl">Top Songs</h4>
                <Button
                  onclick={() =>
                    playArtistsSongs(
                      artist.topSongs.map(track => ({
                        ...track,
                        artists: [artist],
                        videoType: "VIDEO_TYPE_TRACK",
                      })),
                    )}
                >
                  <PlayIcon class="text-primary-foreground" fill="black" /> Play
                </Button>
              </div>
              <div class="px-2">
                {#each artist.topSongs as song}
                  <TrackItem
                    music={{ ...song, artists: [artist], duration: "" }}
                    toggle={{ type: "add" }}
                  />
                {/each}
              </div>
            {/if}
          </section>
          <section>
            {#if artist.albums.length}
              <h4 class="p-2 mb-2 text-3xl">Albums</h4>
              <div class="grid grid-cols-2 gap-4 px-2">
                {#each artist.albums as album}
                  <AlbumTile album={{ ...album, artist }} />
                {/each}
              </div>
            {/if}
          </section>
          <section>
            {#if artist.singlesAndEps.length}
              <h4 class="p-2 mb-2 text-3xl">Singles & EPs</h4>
              <div class="grid grid-cols-2 gap-4 px-2">
                {#each artist.singlesAndEps as singlesAndEp}
                  <AlbumTile album={{ ...singlesAndEp, artist }} />
                {/each}
              </div>
            {/if}
          </section>
        </div>
      </div>
    {/if}
  </div>
</Dialog.Root>
