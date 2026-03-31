<script lang="ts">
  /* eslint-disable svelte/no-at-html-tags */
  import { QueryClient } from "@tanstack/svelte-query";
  import { PersistQueryClientProvider } from "@tanstack/svelte-query-persist-client";
  import { isTauri } from "@tauri-apps/api/core";
  import { Pane, Splitpanes } from "svelte-splitpanes";
  import { pwaInfo } from "virtual:pwa-info";

  import type { Snippet } from "svelte";

  import { getSettings } from "$lib/ipc/settingsManager";
  import connectivityStore from "$lib/stores/connectivity.svelte";
  import musicInterfaceStore from "$lib/stores/musicInterface.svelte.js";
  import settingsStore from "$lib/stores/settings.svelte";
  import { createIDBPersister } from "$lib/utils/cache";

  import BackgroundDownloadManager from "$lib/components/BackgroundDownloadManager.svelte";
  import MusicPlayer from "$lib/components/music-player/MusicPlayer.svelte";
  import MusicPlayerBinder from "$lib/components/music-player/MusicPlayerBinder.svelte";
  import MusicQueueDisplay from "$lib/components/music-queue/MusicQueueDisplay.svelte";
  import SettingsManager from "$lib/components/SettingsManager.svelte";
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
  let sidebarWidth = $derived(20);

  const COLLAPSED_WIDTH = 8;

  const defaultSizes: PaneSizes = $derived({
    sidebar: {
      minSize: 20,
      size: musicInterfaceStore.isMusicQueueVisible ? 20 : 25,
      maxSize: musicInterfaceStore.isMusicQueueVisible ? 20 : 30,
    },
    queue: {
      maxSize: 30,
      size: musicInterfaceStore.isMusicQueueVisible ? 30 : 0,
      minSize: 20,
    },
    content: 80,
  });

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
  let isSidebarCollapsed = $derived(musicInterfaceStore.isMusicQueueVisible);

  $effect(() => {
    const preventRightClick = (e: MouseEvent) => e.preventDefault();
    const recalculateScreenSize = () => (screenSize = window.innerWidth);

    const handleOnOnline = () => (connectivityStore.isOnline = true);
    const handleOnOffline = () => (connectivityStore.isOnline = false);

    if (isTauri()) {
      const fetchSettings = async () => (settingsStore.settings = await getSettings());
      fetchSettings();
    }

    document.addEventListener("contextmenu", preventRightClick);
    document.addEventListener("resize", recalculateScreenSize);
    window.addEventListener("online", handleOnOnline);
    window.addEventListener("offline", handleOnOffline);

    return () => {
      document.removeEventListener("contextmenu", preventRightClick);
      document.removeEventListener("resize", recalculateScreenSize);
      window.removeEventListener("online", handleOnOnline);
      window.removeEventListener("offline", handleOnOffline);
    };
  });

  $effect(() => {
    sidebarWidth = musicInterfaceStore.isMusicQueueVisible
      ? sizes.sidebar.minSize
      : sizes.sidebar.maxSize;
  });

  function toggleSidebar() {
    if (musicInterfaceStore.isMusicQueueVisible) return;
    isSidebarCollapsed = !isSidebarCollapsed;
  }

  const queryClient = new QueryClient();
  const persister = createIDBPersister();
</script>

<svelte:head>
  {@html webManifestLink}
</svelte:head>

<PersistQueryClientProvider client={queryClient} persistOptions={{ persister }}>
  <SettingsManager>
    <BackgroundDownloadManager>
      <Toaster position="top-center" />
      <MusicPlayerBinder />
      <Tooltip.Provider>
        <div class="h-screen flex flex-col bg-extra-dark">
          <div class={isTauri() ? "h-[8vh]" : "h-[10vh] overflow-visible z-9999"}>
            <TopBar />
          </div>
          <Splitpanes
            class="flex-1 overflow-hidden {isTauri() ? 'h-[95vh]' : 'h-[90vh]'}"
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
                {toggleSidebar}
              />
            </Pane>
            <Pane
              class="h-full w-full bg-extra-dark relative"
              size={isSidebarCollapsed ? 92 : sizes.content}
            >
              <main class="bg-extra-dark h-screen">
                {@render children?.()}
              </main>
            </Pane>
            <Pane {...sizes.queue}>
              <div class="relative h-full w-full">
                <MusicQueueDisplay />
              </div>
            </Pane>
          </Splitpanes>
          <div
            class="flex flex-col justify-end items-center w-full absolute bottom-0 {musicInterfaceStore.isPlayerFullscreen
              ? ''
              : 'py-2 px-3'} {musicInterfaceStore.visiblePanel ? 'h-full' : ''}"
          >
            <MusicPlayer />
          </div>
        </div>
      </Tooltip.Provider>
    </BackgroundDownloadManager>
  </SettingsManager>
</PersistQueryClientProvider>
