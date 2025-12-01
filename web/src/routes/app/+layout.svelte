<script lang="ts">
  import { QueryClient } from "@tanstack/svelte-query";
  import { Toaster } from "svelte-french-toast";
  import { Pane, Splitpanes } from "svelte-splitpanes";
  import { fly, slide } from "svelte/transition";

  import type { Snippet } from "svelte";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore from "$lib/stores/music-queue.svelte.js";
  import { createIDBPersister } from "$lib/utils/cache";

  import InfoOverlay from "$lib/components/InfoOverlay.svelte";
  import LyricsOverlay from "$lib/components/LyricsOverlay.svelte";
  import MusicPlayer from "$lib/components/MusicPlayer.svelte";
  import MusicQueueDisplay from "$lib/components/MusicQueueDisplay.svelte";
  import NowPlayingOverlay from "$lib/components/NowPlayingOverlay.svelte";
  import Sidebar from "$lib/components/Sidebar.svelte";
  import TopBar from "$lib/components/TopBar.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import { PersistQueryClientProvider } from "@tanstack/svelte-query-persist-client";
  import type { PageData } from "./$types";

  interface PaneLimit {
    minSize: number;
    maxSize: number;
  }

  interface PaneSizes {
    sidebar: PaneLimit;
    queue: PaneLimit;
    content: number;
  }

  const { children, data }: { children?: Snippet; data: PageData } = $props();

  let screenSize: number | null = $state(null);
  let sidebarWidth = $state(20);

  const defaultSizes: PaneSizes = {
    sidebar: {
      minSize: 6.5,
      maxSize: 28,
    },
    queue: {
      maxSize: 25,
      minSize: 20,
    },
    content: 80,
  };

  function calculateSidebarSize(availableScreenSize: number): PaneSizes {
    if (availableScreenSize <= 968)
      return {
        sidebar: { minSize: 6.5, maxSize: 6.5 },
        queue: { minSize: 0, maxSize: 0 },
        content: 95,
      };

    return defaultSizes;
  }

  let sizes = $derived(screenSize ? calculateSidebarSize(screenSize) : defaultSizes);

  $effect(() => {
    const preventRightClick = (e: MouseEvent) => e.preventDefault();
    const recalculateScreenSize = () => (screenSize = window.innerWidth);

    function handleMusicPlayerSwitchState(e: KeyboardEvent) {
      if (
        e.key === "space" &&
        document.activeElement instanceof HTMLElement &&
        !["INPUT", "TEXTAREA"].includes(document.activeElement.tagName) &&
        !document.activeElement.isContentEditable
      ) {
        e.preventDefault();
        musicPlayerStore.playMusic();
      }
    }

    document.addEventListener("keydown", handleMusicPlayerSwitchState);
    document.addEventListener("contextmenu", preventRightClick);
    document.addEventListener("resize", recalculateScreenSize);

    return () => {
      document.removeEventListener("contextmenu", preventRightClick);
      document.removeEventListener("resize", recalculateScreenSize);
      document.removeEventListener("keydown", handleMusicPlayerSwitchState);
    };
  });

  $effect(() => {
    if (musicQueueStore.isMusicQueueVisible) {
      sidebarWidth = sizes.sidebar.minSize;
    } else {
      sidebarWidth = sizes.sidebar.maxSize;
    }
  });

  const queryClient = new QueryClient();
  const persister = createIDBPersister();
</script>

<PersistQueryClientProvider client={queryClient} persistOptions={{ persister }}>
  <Tooltip.Provider>
    <div class="h-screen flex flex-col bg-extra-dark">
      <Splitpanes class="flex-1 overflow-hidden" on:resize={e => (sidebarWidth = e.detail[0].size)}>
        <Pane class="bg-extra-dark rounded-tr-md" {...sizes.sidebar}>
          <Sidebar {sidebarWidth} />
        </Pane>
        <Pane class="h-full w-full bg-extra-dark relative" size={sizes.content}>
          <TopBar />
          <main class="bg-extra-dark mt-12 h-screen z-30">
            {#if musicQueueStore.musicPlayingNow && musicPlayerStore.visiblePanel}
              <div
                class="absolute inset-x-0 top-[10.5%] bottom-0 z-80 rounded-2xl flex flex-col overflow-hidden"
                in:fly={{ y: 20, duration: 100 }}
                out:fly={{ y: 20, duration: 100 }}
              >
                <InfoOverlay>
                  {#if musicPlayerStore.visiblePanel === "playingNow"}
                    <div in:fly={{ x: -200, y: 0 }} out:fly={{ x: -200, y: 0 }}>
                      <NowPlayingOverlay />
                    </div>
                  {:else if musicPlayerStore.visiblePanel === "lyrics"}
                    <div in:fly={{ x: -200, y: 0 }} out:fly={{ x: 400, y: 0 }}>
                      <LyricsOverlay />
                    </div>
                  {/if}
                </InfoOverlay>
              </div>
            {/if}
            {@render children?.()}
          </main>
        </Pane>
        {#if musicQueueStore.isMusicQueueVisible}
          <Pane {...sizes.queue} class="z-9999">
            <div in:slide={{ duration: 100 }} out:slide={{ duration: 100 }} class="h-full w-full">
              <MusicQueueDisplay />
            </div>
          </Pane>
        {/if}
      </Splitpanes>
      <div class="h-[14%] self-end w-full">
        <MusicPlayer />
      </div>
    </div>
  </Tooltip.Provider>
  <Toaster
    position="bottom-right"
    toastOptions={{ style: `background-color: #111; color: white;` }}
  />
</PersistQueryClientProvider>
