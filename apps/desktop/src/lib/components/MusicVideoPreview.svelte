<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";
  import { onMount } from "svelte";

  import type { PlayerEvent } from "$lib/stream-player/audio/StreamPlayer";

  import { musicPlayer, musicPlayerStreamDevice } from "$lib/stream-player/audio/musicPlayer";
  import { bindPreviewPlayer } from "$lib/stream-player/video/previewPlayer";
  import VideoStreamPlayerFactory from "$lib/stream-player/video/VideoStreamPlayerFactory";

  const { musicVideoId }: { musicVideoId: string } = $props();

  let musicVideoPreviewWebEmbed: HTMLDivElement | null = $state(null);
  let musicVideoPreviewNative: HTMLVideoElement | null = $state(null);

  const previewPlayer = VideoStreamPlayerFactory.create();

  onMount(() => {
    async function loadPreviewPlayer() {
      bindPreviewPlayer(previewPlayer, {
        native: musicVideoPreviewNative ?? undefined,
        webEmbed: musicVideoPreviewWebEmbed ?? undefined,
      });

      await previewPlayer.show(musicVideoId);

      if (musicPlayer.isPlaying) {
        await previewPlayer.sync(musicPlayer.currentTime);
        await previewPlayer.play();
      }
    }

    loadPreviewPlayer();
    return () => previewPlayer.dispose();
  });

  onMount(() => {
    function audioSeekSyncListener(event: PlayerEvent<"timeupdate">) {
      previewPlayer.sync(event.detail.currentTime);
    }

    const audioPlaySyncListener = () => previewPlayer.play();
    const audioPauseSyncListener = () => previewPlayer.pause();

    musicPlayerStreamDevice.on("timeupdate", audioSeekSyncListener);
    musicPlayerStreamDevice.on("playing", audioPlaySyncListener);
    musicPlayerStreamDevice.on("paused", audioPauseSyncListener);
    return () => {
      musicPlayerStreamDevice.off("timeupdate", audioSeekSyncListener);
      musicPlayerStreamDevice.off("playing", audioPlaySyncListener);
      musicPlayerStreamDevice.off("paused", audioPauseSyncListener);
    };
  });

  const playerClasses = "absolute inset-0 w-full h-[102%] object-cover pointer-events-none z-10";
</script>

<div class="relative aspect-square w-full overflow-hidden">
  {#if isTauri()}
    <video id="preview-player" muted loop class={playerClasses} bind:this={musicVideoPreviewNative}>
      <track kind="captions" />
    </video>
  {:else}
    <div id="preview-player" class={playerClasses} bind:this={musicVideoPreviewWebEmbed}></div>
  {/if}
</div>

<style>
  #preview-player::after,
  #preview-player::before {
    -webkit-mask-image: linear-gradient(to bottom, transparent, black 80%);
    mask-image: linear-gradient(to bottom, transparent, black 80%);
  }
</style>
