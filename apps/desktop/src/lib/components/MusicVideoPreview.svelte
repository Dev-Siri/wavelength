<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";

  import { NATIVE_PLAYBACK_FORMAT } from "$lib/stream-player/NativePlayer";
  import { bindPreviewPlayer } from "$lib/stream-player/previewPlayer";
  import StreamPlayerFactory from "$lib/stream-player/StreamPlayerBuilder";

  const { musicVideoId }: { musicVideoId: string } = $props();

  let musicVideoPreviewWebEmbed: HTMLDivElement | null = $state(null);
  let musicVideoPreviewNative: HTMLVideoElement | null = $state(null);

  const { musicPlayerStreamDevice, musicPlayerWebCompatibilityDevice } = StreamPlayerFactory.create(
    {
      nativeOptions: { format: NATIVE_PLAYBACK_FORMAT.VIDEO },
      webOptions: {
        playerVars: {
          start: 10,
          loop: 1,
          playlist: musicVideoId,
          autoplay: 0,
          controls: 0,
          disablekb: 1,
          playsinline: 1,
        },
      },
    },
  );

  $effect(() => {
    bindPreviewPlayer(isTauri() ? musicPlayerStreamDevice : musicPlayerWebCompatibilityDevice!, {
      native: musicVideoPreviewNative ?? undefined,
      webEmbed: musicVideoPreviewWebEmbed ?? undefined,
    });
    (isTauri() ? musicPlayerStreamDevice : musicPlayerWebCompatibilityDevice)?.load(musicVideoId);
  });
  const playerClasses = "absolute inset-0 w-full h-full object-cover pointer-events-none z-10";
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
