<script lang="ts">
  import { dev } from "$app/environment";

  import { injectAnalytics } from "@vercel/analytics/sveltekit";

  import { injectSpeedInsights } from "@vercel/speed-insights/sveltekit";
  import { onMount } from "svelte";
  import { Toaster } from "svelte-french-toast";
  import { Pane, Splitpanes } from "svelte-splitpanes";
  import { fly } from "svelte/transition";
  import "../app.css";

  import type { User } from "@auth/sveltekit";

  import { visiblePanel } from "$lib/stores/music-player";
  import { musicPlayingNow } from "$lib/stores/music-queue";
  import { user } from "$lib/stores/user";

  import InfoOverlay from "$lib/components/InfoOverlay.svelte";
  import LyricsOverlay from "$lib/components/LyricsOverlay.svelte";
  import MusicPlayer from "$lib/components/MusicPlayer.svelte";
  import NowPlayingOverlay from "$lib/components/NowPlayingOverlay.svelte";
  import Sidebar from "$lib/components/Sidebar.svelte";
  import TopBar from "$lib/components/TopBar.svelte";

  injectAnalytics({ mode: dev ? "development" : "production" });
  injectSpeedInsights();

  interface PaneSizes {
    sidebar: {
      minSize: number;
      maxSize: number;
    };
    content: number;
  }

  export let data;

  let screenSize: number | null = null;

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

  let sizes = screenSize ? calculateSidebarSize(screenSize) : defaultSizes;
  const {
    sidebar: { maxSize, minSize },
    content,
  } = sizes;

  onMount(() => {
    const preventRightClick = (e: MouseEvent) => e.preventDefault();
    const recalculateScreenSize = () => {
      screenSize = window.innerWidth;
      sizes = calculateSidebarSize(screenSize);
    };

    document.addEventListener("contextmenu", preventRightClick);
    document.addEventListener("resize", recalculateScreenSize);

    return () => {
      document.removeEventListener("contextmenu", preventRightClick);
      document.removeEventListener("resize", recalculateScreenSize);
    };
  });

  const { region, session } = data;

  $: $user = session?.user as User | null;
</script>

<svelte:head>
  <title>WaveLength</title>
  <meta name="description" content="Call this a glorified YouTube Music Wrapper." />
</svelte:head>

<div class="h-screen">
  <Splitpanes class="h-[86vh]">
    <Pane class="bg-primary-foreground rounded-tr-md rounded-br-md" {minSize} {maxSize}>
      <Sidebar />
    </Pane>
    <Pane class="h-full w-full bg-primary-foreground" size={content}>
      <TopBar {region} />
      <main
        class="pt-[3.5%] mt-[8%] min-923:mt-[4.5%] lg:mt-[3%] bg-primary-foreground h-screen rounded-tl-md z-30"
      >
        {#if $musicPlayingNow && $visiblePanel}
          <div
            class="absolute h-[76%] bg-primary-foreground w-[80%] z-[100] rounded-2xl"
            in:fly={{ y: 20, duration: 100 }}
            out:fly={{ y: 20, duration: 100 }}
          >
            <InfoOverlay>
              {#if $visiblePanel === "playingNow"}
                <div in:fly={{ x: -200, y: 0 }} out:fly={{ x: -200, y: 0 }}>
                  <NowPlayingOverlay />
                </div>
              {:else if $visiblePanel === "lyrics"}
                <div in:fly={{ x: -200, y: 0 }} out:fly={{ x: 400, y: 0 }}>
                  <LyricsOverlay />
                </div>
              {/if}
            </InfoOverlay>
          </div>
        {/if}
        <slot />
      </main>
    </Pane>
  </Splitpanes>
  <div class="absolute inset-0 z-[150] h-[14vh] self-end w-full">
    <MusicPlayer />
  </div>
</div>
<Toaster
  position="bottom-right"
  toastOptions={{ style: `background-color: #111; color: white;` }}
/>
