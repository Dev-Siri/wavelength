<script lang="ts">
  import { QueryClient } from "@tanstack/svelte-query";
  import { PersistQueryClientProvider } from "@tanstack/svelte-query-persist-client";
  import { Pane, Splitpanes } from "svelte-splitpanes";
  import { fly } from "svelte/transition";
  import { pwaInfo } from "virtual:pwa-info";

  import type { Snippet } from "svelte";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore from "$lib/stores/music-queue.svelte.js";
  import { createIDBPersister } from "$lib/utils/cache";

  import BackgroundDownloadManager from "$lib/components/BackgroundDownloadManager.svelte";
  import LyricsOverlay from "$lib/components/LyricsOverlay.svelte";
  import MusicPlayer from "$lib/components/music-player/MusicPlayer.svelte";
  import MusicQueueDisplay from "$lib/components/music-queue/MusicQueueDisplay.svelte";
  import InfoOverlay from "$lib/components/overlays/InfoOverlay.svelte";
  import NowPlayingOverlay from "$lib/components/overlays/NowPlayingOverlay.svelte";
  import Sidebar from "$lib/components/Sidebar.svelte";
  import TopBar from "$lib/components/TopBar.svelte";
  import { Toaster } from "$lib/components/ui/sonner";
  import * as Tooltip from "$lib/components/ui/tooltip";

  interface PaneLimit {
    minSize: number;
    size?: number;
    maxSize: number;
  }

  interface PaneSizes {
    sidebar: PaneLimit;
    queue: PaneLimit;
    content: number;
  }

  const { children }: { children?: Snippet } = $props();

  const webManifestLink = pwaInfo ? pwaInfo.webManifest.linkTag : "";

  let screenSize: number | null = $state(null);
  let sidebarWidth = $state(20);

  const COLLAPSED_WIDTH = 8;

  const defaultSizes: PaneSizes = {
    sidebar: {
      minSize: 20,
      size: 25,
      maxSize: 30,
    },
    queue: {
      maxSize: 25,
      size: 25,
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
  let isSidebarCollapsed = $derived(false);

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
    sidebarWidth = musicQueueStore.isMusicQueueVisible
      ? sizes.sidebar.minSize
      : sizes.sidebar.maxSize;
  });

  const queryClient = new QueryClient();
  const persister = createIDBPersister();
</script>

<svelte:head>
  {@html webManifestLink}
</svelte:head>

<PersistQueryClientProvider client={queryClient} persistOptions={{ persister }}>
  <BackgroundDownloadManager>
    <Toaster position="top-center" />
    <Tooltip.Provider>
      <div class="h-screen flex flex-col bg-extra-dark">
        <div class="h-[10vh]">
          <TopBar />
        </div>
        <Splitpanes
          class="h-[90vh] flex-1 overflow-hidden"
          on:resize={e => (sidebarWidth = e.detail[0].size)}
        >
          <Pane
            class="bg-extra-dark rounded-tr-md"
            {...sizes.sidebar}
            minSize={isSidebarCollapsed ? COLLAPSED_WIDTH : sizes.sidebar.minSize}
            maxSize={isSidebarCollapsed ? COLLAPSED_WIDTH : sizes.sidebar.maxSize}
            size={isSidebarCollapsed ? COLLAPSED_WIDTH : sidebarWidth}
          >
            <Sidebar
              isCollapsed={isSidebarCollapsed || window.innerWidth <= 640}
              toggleSidebar={() => (isSidebarCollapsed = !isSidebarCollapsed)}
            />
          </Pane>
          <Pane
            class="h-full w-full bg-extra-dark relative"
            size={isSidebarCollapsed ? 92 : sizes.content}
          >
            <main class="bg-extra-dark h-screen">
              {#if musicQueueStore.musicPlayingNow && musicPlayerStore.visiblePanel}
                <div
                  class="absolute inset-x-0 top-[10.5%] bottom-0 z-80 rounded-2xl flex flex-col overflow-hidden"
                  in:fly={{ y: 20, duration: 250 }}
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
              <div class="h-full w-full">
                <MusicQueueDisplay />
              </div>
            </Pane>
          {/if}
        </Splitpanes>
        <div class="h-[10vh] self-end w-full">
          <MusicPlayer />
        </div>
      </div>
    </Tooltip.Provider>
  </BackgroundDownloadManager>
</PersistQueryClientProvider>
