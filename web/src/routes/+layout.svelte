<script lang="ts">
  import { dev } from "$app/environment";
  import { injectAnalytics } from "@vercel/analytics/sveltekit";
  import { injectSpeedInsights } from "@vercel/speed-insights/sveltekit";
  import { Toaster } from "svelte-french-toast";
  import { Pane, Splitpanes } from "svelte-splitpanes";
  import { fly } from "svelte/transition";
  import "../app.css";

  import type { User } from "@auth/sveltekit";
  import type { Snippet } from "svelte";
  import type { LayoutData } from "./$types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import userStore from "$lib/stores/user.svelte";

  import InfoOverlay from "$lib/components/InfoOverlay.svelte";
  import LyricsOverlay from "$lib/components/LyricsOverlay.svelte";
  import MusicPlayer from "$lib/components/MusicPlayer.svelte";
  import NowPlayingOverlay from "$lib/components/NowPlayingOverlay.svelte";
  import Sidebar from "$lib/components/Sidebar.svelte";
  import TopBar from "$lib/components/TopBar.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";

  injectAnalytics({ mode: dev ? "development" : "production" });
  injectSpeedInsights();

  interface PaneSizes {
    sidebar: {
      minSize: number;
      maxSize: number;
    };
    content: number;
  }

  const { children, data }: { data: LayoutData; children?: Snippet } = $props();

  let screenSize: number | null = $state(null);

  const defaultSizes: PaneSizes = {
    sidebar: {
      minSize: 23,
      maxSize: 28,
    },
    content: 80,
  };

  function calculateSidebarSize(availableScreenSize: number): PaneSizes {
    if (availableScreenSize <= 968)
      return {
        sidebar: { minSize: 5, maxSize: 5 },
        content: 95,
      };

    return defaultSizes;
  }

  let sizes = $derived(screenSize ? calculateSidebarSize(screenSize) : defaultSizes);

  $effect(() => {
    const preventRightClick = (e: MouseEvent) => e.preventDefault();
    const recalculateScreenSize = () => (screenSize = window.innerWidth);

    document.addEventListener("contextmenu", preventRightClick);
    document.addEventListener("resize", recalculateScreenSize);

    return () => {
      document.removeEventListener("contextmenu", preventRightClick);
      document.removeEventListener("resize", recalculateScreenSize);
    };
  });

  const { region, session } = data;

  $effect(() => {
    userStore.user = session?.user as User | null;
  });
</script>

<svelte:head>
  <title>WaveLength</title>
  <meta name="description" content="Call this a glorified YouTube Music Wrapper." />
</svelte:head>

<Tooltip.Provider>
  <div class="h-screen">
    <Splitpanes class="h-[86vh]">
      <Pane class="bg-primary-foreground rounded-tr-md rounded-br-md" {...sizes.sidebar}>
        <Sidebar />
      </Pane>
      <Pane class="h-full w-full bg-primary-foreground" size={sizes.content}>
        <TopBar {region} />
        <main
          class="pt-[3.5%] mt-[8%] min-923:mt-[4.5%] lg:mt-[3%] bg-primary-foreground h-screen rounded-tl-md z-30"
        >
          {#if musicQueueStore.musicPlayingNow && musicPlayerStore.visiblePanel}
            <div
              class="absolute h-[76%] bg-primary-foreground w-[80%] z-80 rounded-2xl"
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
    <div class="absolute inset-0 z-150 h-[14vh] self-end w-full">
      <MusicPlayer />
    </div>
  </div>
</Tooltip.Provider>
<Toaster
  position="bottom-right"
  toastOptions={{ style: `background-color: #111; color: white;` }}
/>
