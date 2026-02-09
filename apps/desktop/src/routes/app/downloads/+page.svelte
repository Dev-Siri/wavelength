<script lang="ts">
  import { BookmarkIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { isTauri } from "@tauri-apps/api/core";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import downloadStore from "$lib/stores/download.svelte";
  import { fetchDownloads } from "$lib/utils/download";

  import Logo from "$lib/components/Logo.svelte";
  import Track from "$lib/components/track/Track.svelte";

  $effect(() => {
    if (!isTauri()) history.back();
  });

  const downloadsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.downloads,
    queryFn: fetchDownloads,
  }));
</script>

<div class="h-full w-full overflow-y-auto pb-[20%] bg-black p-4">
  {#if downloadStore.activeDownloads.length}
    <section class="mb-2">
      <header class="flex items-center gap-2">
        <BookmarkIcon size={18} />
        <h1 class="text-xl font-semibold select-none duration-200">Active Downloads</h1>
      </header>
      {#each downloadStore.activeDownloads as download}
        <Track music={download} toggle={{ type: "add" }} />
      {/each}
    </section>
  {/if}
  <section>
    <header class="flex items-center gap-2">
      <BookmarkIcon size={18} />
      <h1 class="text-xl font-semibold select-none duration-200">Your Downloads</h1>
    </header>
    {#if downloadsQuery.data?.length}
      <div class="mt-2">
        {#each downloadsQuery.data as download}
          <Track music={download} toggle={{ type: "add" }} />
        {/each}
      </div>
    {:else}
      <div class="h-1/2 w-full flex flex-col gap-2 items-center justify-center">
        <Logo />
        <p class="text-lg">You have no songs downloaded.</p>
      </div>
    {/if}
  </section>
</div>
