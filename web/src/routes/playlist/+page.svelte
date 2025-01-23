<script lang="ts">
  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import { fly } from "svelte/transition";

  import type { FormInputEvent } from "$lib/components/ui/input";

  import debounce from "$lib/utils/debounce";

  import PlaylistCard from "$lib/components/PlaylistCard.svelte";
  import TrackItemSkeleton from "$lib/components/skeletons/TrackItemSkeleton.svelte";
  import Input from "$lib/components/ui/input/input.svelte";
  import { onMount } from "svelte";

  export let data;

  let inputValue = $page.url.searchParams.get("q") ?? "";
  let debouncedHandleOnInput: (e: FormInputEvent<InputEvent>) => void;

  function handleOnInput(e: FormInputEvent<InputEvent>) {
    console.log("i run", e);

    if (inputValue === "") {
      goto("/playlist");
    } else {
      goto(`/playlist?q=${encodeURIComponent(inputValue)}`);
    }
  }

  onMount(() => {
    debouncedHandleOnInput = debounce(handleOnInput);
  });
</script>

<div
  class="h-full w-full p-4 bg-black rounded-2xl"
  in:fly={{ y: 20, duration: 100 }}
  out:fly={{ y: 20, duration: 100 }}
>
  <form action="/playlist" method="GET" class="w-full">
    <Input
      name="q"
      placeholder="Search for playlists..."
      class="mb-4"
      bind:value={inputValue}
      on:input={debouncedHandleOnInput}
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
            <PlaylistCard imageClasses="h-12 w-[52px]" {playlist} />
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
