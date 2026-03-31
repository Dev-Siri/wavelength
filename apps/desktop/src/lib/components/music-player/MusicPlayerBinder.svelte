<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";

  import { bindPlayerToApp, musicPlayer } from "$lib/stream-player/musicPlayer";

  let nativePlayer: HTMLAudioElement;
  let webEmbedPlayer: HTMLDivElement | undefined = $state(undefined);

  $effect(() => {
    const dispose = bindPlayerToApp({
      native: nativePlayer,
      webEmbed: webEmbedPlayer,
    });

    return () => {
      dispose();
      musicPlayer.dispose();
    };
  });
</script>

<audio class="hidden" bind:this={nativePlayer}></audio>
{#if !isTauri()}
  <div class="hidden" bind:this={webEmbedPlayer}></div>
{/if}
