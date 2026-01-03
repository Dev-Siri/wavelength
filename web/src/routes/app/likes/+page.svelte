<script lang="ts">
  import { ClockIcon, HeartIcon, HeartPlusIcon, PlayIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { fly } from "svelte/transition";

  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import userStore from "$lib/stores/user.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { likedTracksSchema } from "$lib/utils/validation/liked-track";
  import { likedTracksLengthSchema } from "$lib/utils/validation/track-length";

  import Image from "$lib/components/Image.svelte";
  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import PlaylistLength from "$lib/components/PlaylistLength.svelte";
  import TrackItem from "$lib/components/TrackItem.svelte";
  import { Button } from "$lib/components/ui/button";

  function playLikes(songs: QueueableMusic[]) {
    musicQueueStore.addToQueue(...songs);
    musicQueueStore.musicPlayingNow = songs[0];
    musicPlayerStore.playMusic();
  }

  const likedTracksQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.likes,
    queryFn: () => backendClient("/music/track/likes", likedTracksSchema),
  }));

  const likesPlaylengthQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.likesLength,
    queryFn: () => backendClient("/music/track/likes/length", likedTracksLengthSchema),
  }));
</script>

<svelte:head>
  <title>
    {userStore.user?.name ? `${userStore.user.name}'s Liked Songs` : "Liked Songs"}
  </title>
</svelte:head>

{#if userStore.user}
  <div
    class="flex flex-col h-full w-full bg-black rounded-2xl overflow-y-auto"
    in:fly={{ y: 20, duration: 250 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    <div class="w-full p-4 pb-2 bg-black h-full mt-4 sm:mt-6 lg:mt-1 rounded-2xl">
      <div class="relative flex gap-4 mt-4">
        {#if userStore.user.image}
          {#key userStore.user.image}
            <div class="grid place-items-center h-48 w-48 rounded-2xl like-gradient">
              <HeartIcon fill="white" size={50} />
            </div>
          {/key}
        {:else}
          <div class="h-48 w-48 rounded-2xl aspect-square bg-muted"></div>
        {/if}
        <div class="flex flex-col w-3/5 h-full gap-2">
          <h1 class="text-6xl font-extrabold">Likes</h1>
          <div class="flex gap-2 items-center">
            {#if userStore.user.image}
              {#key userStore.user.image}
                <Image
                  src={userStore.user.image}
                  alt="{userStore.user.name}'s Picture"
                  height={40}
                  width={40}
                  class="rounded-full"
                />
              {/key}
            {/if}
            <p class="font-semibold">
              {userStore.user.name}
              {#key likesPlaylengthQuery.dataUpdatedAt}
                {#if likesPlaylengthQuery.isSuccess}
                  <PlaylistLength
                    playlistTrackLength={likesPlaylengthQuery.data.likedTracksLength}
                  />
                {/if}
              {/key}
            </p>
          </div>
        </div>
      </div>
      <div class="h-full bg-black">
        {#if likedTracksQuery.isLoading}
          <div class="w-full flex items-center justify-center py-20">
            <LoadingSpinner />
          </div>
        {:else if likedTracksQuery.isSuccess}
          {@const { likedTracks } = likedTracksQuery.data}
          {#if likedTracks.length}
            <div class="flex items-center gap-2">
              <Button
                class="rounded-full w-fit my-3 py-6 ml-1 z-10"
                onclick={() => playLikes(likedTracks ?? [])}
              >
                <PlayIcon class="text-primary-foreground" fill="black" />
              </Button>
            </div>
            <header
              class="flex pl-14 justify-around items-center gap-5 select-none text-muted-foreground"
            >
              <p class="flex-2">Title</p>
              <ClockIcon size={18} class="mr-28" />
            </header>
            <div class="mt-2 overflow-x-hidden pb-[80%] md:pb-[40%] lg:pb-[20%]">
              {#key likedTracks}
                {#each likedTracks as likedTrack}
                  <TrackItem music={likedTrack} toggle={{ type: "add" }} />
                {/each}
              {/key}
            </div>
          {:else}
            <div class="mt-10 flex gap-2 flex-col items-center justify-center">
              <HeartPlusIcon size={40} />
              <h4 class="text-center text-2xl">Your likes are empty.</h4>
              <Button
                variant="secondary"
                onclick={() => document.getElementById("search-input")?.focus()}
              >
                Discover new music
              </Button>
            </div>
          {/if}
        {/if}
      </div>
    </div>
  </div>
{/if}
