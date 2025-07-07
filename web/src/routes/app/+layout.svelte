<script lang="ts">
  import { Toaster } from "svelte-french-toast";
  import { Pane, Splitpanes } from "svelte-splitpanes";
  import { fly } from "svelte/transition";

  import type { Snippet } from "svelte";
  import type { LayoutData } from "./$types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import InfoOverlay from "$lib/components/InfoOverlay.svelte";
  import LyricsOverlay from "$lib/components/LyricsOverlay.svelte";
  import MusicPlayer from "$lib/components/MusicPlayer.svelte";
  import NowPlayingOverlay from "$lib/components/NowPlayingOverlay.svelte";
  import Sidebar from "$lib/components/Sidebar.svelte";
  import TopBar from "$lib/components/TopBar.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";

  interface PaneSizes {
    sidebar: {
      minSize: number;
      maxSize: number;
    };
    content: number;
  }

  const { children, data }: { data: LayoutData; children?: Snippet } = $props();

  let screenSize: number | null = $state(null);
  let paneWidth: number = $state(20);

  const defaultSizes: PaneSizes = {
    sidebar: {
      minSize: 6.5,
      maxSize: 28,
    },
    content: 80,
  };

  function calculateSidebarSize(availableScreenSize: number): PaneSizes {
    if (availableScreenSize <= 968)
      return {
        sidebar: { minSize: 6.5, maxSize: 6.5 },
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
</script>

<Tooltip.Provider>
  <div class="h-screen flex flex-col bg-primary-foreground">
    <Splitpanes class="flex-1 overflow-hidden" on:resize={e => (paneWidth = e.detail[0].size)}>
      <Pane class="bg-primary-foreground rounded-tr-md rounded-br-md" {...sizes.sidebar}>
        <Sidebar {paneWidth} />
      </Pane>
      <Pane class="h-full w-full bg-primary-foreground relative" size={sizes.content}>
        <TopBar region={data.region} />
        <main class="bg-primary-foreground mt-12 h-screen z-30">
          {#if musicQueueStore.musicPlayingNow && musicPlayerStore.visiblePanel}
            <div
              class="absolute inset-0 top-[10.5%] h-full w-full z-80 rounded-2xl"
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
