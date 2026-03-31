<script lang="ts">
  import { BookmarkIcon } from "@lucide/svelte";
  import { isTauri } from "@tauri-apps/api/core";
  import { listen } from "@tauri-apps/api/event";

  import type { MusicPlaylistContextSource } from "$lib/stream-player/MusicQueue.svelte";

  import { DOWNLOAD_EVENTS } from "$lib/constants/tauri";
  import useDownloadsQuery from "$lib/queries/downloads";
  import downloadStore from "$lib/stores/download.svelte";

  import Logo from "$lib/components/Logo.svelte";
  import Track from "$lib/components/track/Track.svelte";
  import ActiveDownload from "./active-download.svelte";

  $effect(() => {
    if (!isTauri()) history.back();
  });

  const downloadsQuery = useDownloadsQuery();

  let downloadState: number | null = $state(null);

  $effect(() => {
    const downloadStartListener = listen<string>(DOWNLOAD_EVENTS.start, () => (downloadState = 0));

    const downloadProgressListener = listen<number>(
      DOWNLOAD_EVENTS.progress,
      ({ payload }) => (downloadState = payload),
    );

    const downloadEndListener = listen<string>(DOWNLOAD_EVENTS.end, () => (downloadState = null));

    return () => {
      downloadStartListener.then(unlisten => unlisten());
      downloadProgressListener.then(unlisten => unlisten());
      downloadEndListener.then(unlisten => unlisten());
    };
  });

  const context = {
    type: "downloads",
    sourceName: "Downloads",
  } satisfies MusicPlaylistContextSource;
</script>

<div class="h-full w-full overflow-y-auto pb-[20%] bg-black p-4">
  <section class="mb-2">
    {#if downloadStore.currentDownload && downloadState}
      <header class="flex items-center gap-2">
        <BookmarkIcon size={18} />
        <h1 class="text-xl font-semibold select-none duration-200">Active Downloads</h1>
      </header>
      <div class="my-4">
        <ActiveDownload
          track={downloadStore.currentDownload.track}
          progressPercent={downloadState}
        />
      </div>
      {#if downloadStore.activeDownloads.length}
        {#each downloadStore.activeDownloads as download (download.downloadId)}
          <Track {context} music={download.track} toggle={{ type: "add" }} />
        {/each}
      {/if}
    {/if}
  </section>
  <section>
    <header class="flex items-center gap-2">
      <BookmarkIcon size={18} />
      <h1 class="text-xl font-semibold select-none duration-200">Your Downloads</h1>
    </header>
    {#if downloadsQuery.data?.length}
      <div class="mt-2">
        {#each downloadsQuery.data as download (download.videoId)}
          <Track {context} music={download} toggle={{ type: "add" }} />
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
