<script lang="ts">
  import { goto } from "$app/navigation";
  import { page } from "$app/state";
  import { fly } from "svelte/transition";

  import debounce from "$lib/utils/debounce";

  import type { PageProps } from "./$types";

  import PlaylistCard from "$lib/components/PlaylistCard.svelte";
  import TrackItemSkeleton from "$lib/components/skeletons/TrackItemSkeleton.svelte";
  import Input from "$lib/components/ui/input/input.svelte";

  const { data }: PageProps = $props();

  function handleOnInput(e: Event & { currentTarget: EventTarget & HTMLInputElement }) {
    if (inputValue === "") return goto("/playlist");

    goto(`/playlist?q=${encodeURIComponent(inputValue)}`);
  }

  let inputValue = $state(page.url.searchParams.get("q") ?? "");
  let debouncedHandleOnInput: (
    e: Event & { currentTarget: EventTarget & HTMLInputElement },
  ) => void = $state(handleOnInput);

  $effect(() => {
    debouncedHandleOnInput = debounce(handleOnInput);
  });
</script>

<div
  class="h-full w-full p-4 bg-black rounded-2xl pt-10"
  in:fly={{ y: 20, duration: 100 }}
  out:fly={{ y: 20, duration: 100 }}
>
  <form action="/app/playlist" method="GET" class="w-full">
    <Input
      name="q"
      placeholder="Search for playlists..."
      class="mb-4 duration-200"
      bind:value={inputValue}
      oninput={debouncedHandleOnInput}
    />
  </form>
  {#await data.pageData.publicPlaylistsResponse}
    <TrackItemSkeleton />
    <TrackItemSkeleton />
    <TrackItemSkeleton />
  {:then publicPlaylists}
    {#if publicPlaylists.success}
      <div class="flex flex-col h-full items-center pb-32 rounded-2xl">
        {#if publicPlaylists.data.length}
          {#each publicPlaylists.data as playlist}
            <PlaylistCard imageClasses="h-10 w-11" {playlist} />
          {/each}
        {:else}
          <span class="text-5xl text-balance font-black mt-[20%]">
            No public playlists found.
          </span>
        {/if}
      </div>
    {/if}
  {/await}
</div>
