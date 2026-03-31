<script lang="ts">
  import { ClockIcon, HeartIcon, HeartPlusIcon } from "@lucide/svelte";
  import { fly } from "svelte/transition";

  import type { MusicPlaylistContextSource } from "$lib/stream-player/MusicQueue.svelte";

  import useLikesQuery from "$lib/queries/likes";
  import useLikesPlaylengthQuery from "$lib/queries/likesPlaylength";
  import userStore from "$lib/stores/user.svelte.js";

  import Image from "$lib/components/Image.svelte";
  import PlaylistLength from "$lib/components/playlist/PlaylistLength.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import TrackItem from "$lib/components/track/Track.svelte";
  import { Button } from "$lib/components/ui/button";
  import Spinner from "$lib/components/ui/spinner/spinner.svelte";

  const likedTracksQuery = useLikesQuery();
  const likesPlaylengthQuery = useLikesPlaylengthQuery();

  const context = $derived({
    sourceName: "Liked Songs",
    type: "likes",
    email: userStore.user?.email ?? "",
  } satisfies MusicPlaylistContextSource);

  const likedTracks = $derived.by(() => {
    if (!likedTracksQuery.data?.likedTracks) return [];
    return likedTracksQuery.data.likedTracks;
  });
</script>

<svelte:head>
  <title>
    {userStore.user?.displayName ? `${userStore.user.displayName}'s Liked Songs` : "Liked Songs"}
  </title>
</svelte:head>

{#if userStore.user}
  <div
    class="flex flex-col h-full w-full bg-secondary/30 rounded-2xl overflow-y-auto"
    in:fly={{ y: 20, duration: 250 }}
    out:fly={{ y: 20, duration: 100 }}
  >
    <div class="w-full p-4 pb-2 h-full mt-4 sm:mt-6 lg:mt-1 rounded-2xl">
      <div class="flex gap-4">
        {#if userStore.user.pictureUrl}
          {#key userStore.user.pictureUrl}
            <div class="grid place-items-center h-56 w-56 rounded-sm like-gradient">
              <HeartIcon fill="white" size={50} />
            </div>
          {/key}
        {:else}
          <div class="h-48 w-48 rounded-2xl aspect-square bg-muted"></div>
        {/if}
        <div class="flex flex-col justify-center w-3/5 h-60 gap-2">
          <h1 class="text-6xl lg:text-7xl font-semibold">Liked Songs</h1>
          <div class="flex gap-2 items-center">
            {#if userStore.user.pictureUrl}
              {#key userStore.user.pictureUrl}
                <Image
                  src={userStore.user.pictureUrl}
                  alt="{userStore.user.displayName}'s Picture"
                  height={32}
                  width={32}
                  class="rounded-full"
                />
              {/key}
            {/if}
            <p class="text-sm">
              {userStore.user.displayName}
              {#key likesPlaylengthQuery.dataUpdatedAt}
                {#if likesPlaylengthQuery.isSuccess}
                  <PlaylistLength
                    playlistTrackLength={likesPlaylengthQuery.data.likedTracksLength}
                  />
                {/if}
              {/key}
            </p>
          </div>
          <div class="mt-4">
            <PlaylistPlayOptions {context} tracks={likedTracks} />
          </div>
        </div>
      </div>
      <div class="h-full">
        {#if likedTracksQuery.isLoading}
          <div class="w-full flex items-center justify-center py-20">
            <Spinner class="size-28" />
          </div>
        {:else if likedTracksQuery.isSuccess}
          {#if likedTracks.length}
            <header class="flex items-center select-none text-muted-foreground">
              <section class="flex pl-16 items-center gap-10 w-1/3">
                <p class="text-sm">Title</p>
              </section>
              <section class="flex justify-center w-1/3">
                <p class="text-sm">Album</p>
              </section>
              <section class="flex justify-center w-1/3">
                <ClockIcon size={14} class="mr-6" />
              </section>
            </header>
            <div class="bg-secondary h-[1px] w-full my-2.5 rounded-full"></div>
            <div class="mt-2 overflow-x-hidden pb-[80%] md:pb-[40%] lg:pb-[20%]">
              {#key likedTracks}
                {#each likedTracks as likedTrack (likedTrack.videoId)}
                  <TrackItem isPreLiked music={likedTrack} toggle={{ type: "add" }} {context} />
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
