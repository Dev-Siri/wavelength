<script lang="ts">
  import { blur } from "svelte/transition";

  import useCoverEffectQuery from "$lib/queries/coverEffect";
  import useThemeColorQuery from "$lib/queries/themeColor";
  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  import userStore from "$lib/stores/user.svelte";
  import MusicQueueDisplay from "../music-queue/MusicQueueDisplay.svelte";
  import InfoOverlay from "../overlays/InfoOverlay.svelte";
  import LyricsOverlay from "../overlays/LyricsOverlay.svelte";
  import LoggedOutMusicPlayer from "./LoggedOutMusicPlayer.svelte";
  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerFullscreenCoverEffect from "./MusicPlayerFullscreenCoverEffect.svelte";
  import MusicPlayerPlaybackOptions from "./MusicPlayerPlaybackOptions.svelte";
  import MusicPlayerProgressBar from "./MusicPlayerProgressBar.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";

  const themeColorQuery = $derived(
    useThemeColorQuery(musicPlayer.queue.playingNow?.thumbnail ?? "", {
      cacheKey: musicPlayer.queue.playingNow?.videoId ?? "",
      enabled: () => !!musicPlayer.queue.playingNow,
    }),
  );

  const coverEffectQuery = $derived(
    useCoverEffectQuery(musicPlayer.queue.playingNow?.thumbnail ?? "", {
      cacheKey: musicPlayer.queue.playingNow?.videoId ?? "",
      enabled: () => !!musicPlayer.queue.playingNow,
    }),
  );

  const DEFAULT_COLOR = "rgb(0, 0, 0, 0.5)";

  const themeColor = $derived.by(() => {
    if (musicInterfaceStore.isPlayerFullscreen) {
      if (!coverEffectQuery.data?.colors) return DEFAULT_COLOR;

      const { r, g, b } = coverEffectQuery.data.colors[0];
      return `rgb(${r}, ${g}, ${b})`;
    }

    if (!themeColorQuery.data) return DEFAULT_COLOR;

    const { r, g, b } = themeColorQuery.data;
    return `rgb(${r}, ${g}, ${b}, 0.7)`;
  });

  const visiblePanelStyles = $derived(
    musicInterfaceStore.visiblePanel && musicPlayer.queue.playingNow ? "h-full" : "h-fit",
  );
</script>

<div
  class="flex flex-col justify-between bg-primary-foreground backdrop-blur-sm overflow-hidden transition-all w-full max-h-full z-9999 {visiblePanelStyles} {musicInterfaceStore.isPlayerFullscreen &&
  musicPlayer.queue.playingNow
    ? ''
    : 'rounded-xl'}"
  style="background-color: {themeColor};"
>
  {#if userStore.user}
    {#if musicInterfaceStore.isPlayerFullscreen && musicPlayer.queue.playingNow}
      <div class="absolute inset-0 bg-black/40 pointer-events-none"></div>
      {#if coverEffectQuery.data?.colors}
        <MusicPlayerFullscreenCoverEffect coverColors={coverEffectQuery.data.colors} />
      {/if}
    {/if}
    {#if musicInterfaceStore.visiblePanel && musicPlayer.queue.playingNow}
      <div in:blur class="w-full px-4 overflow-hidden z-10">
        <InfoOverlay>
          {#if musicInterfaceStore.visiblePanel === "lyrics" && musicPlayer.queue.playingNow.videoType === "VIDEO_TYPE_TRACK"}
            <div in:blur class="h-full w-full">
              <LyricsOverlay />
            </div>
          {/if}
          {#if musicPlayer.queue.playingNow.videoType === "VIDEO_TYPE_UVIDEO" || musicInterfaceStore.visiblePanel === "queue"}
            <div in:blur class="h-full w-full overflow-hidden rounded-2xl">
              <MusicQueueDisplay class="bg-secondary/30 backdrop-blur-3xl" presentationOnly />
            </div>
          {/if}
        </InfoOverlay>
      </div>
    {/if}
  {/if}
  {#if !musicInterfaceStore.isPlayerFullscreen}
    <div class="flex items-center flex-1 shrink-0 pl-2">
      {#if userStore.user}
        <section class="flex h-full w-1/3 items-center">
          <MusicPlayerTrackLabel />
        </section>
        <section class="flex flex-col items-center justify-center gap-2 h-full w-1/3">
          <MusicPlayerControls />
          <MusicPlayerProgressBar />
        </section>
        <section class="flex items-center justify-end pr-10 h-full gap-1 w-1/3 md:pl-[5%]">
          <MusicPlayerPlaybackOptions />
        </section>
      {:else}
        <LoggedOutMusicPlayer />
      {/if}
    </div>
  {/if}
</div>
