<script lang="ts">
  import { setupEventListeners } from "$lib/stream-player/audio/eventListeners";
  import { bindPlayerToApp, musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  let nativePlayer: HTMLAudioElement;

  $effect(() => {
    bindPlayerToApp(nativePlayer);
    const dispose = setupEventListeners();

    return () => {
      musicPlayer.dispose();
      dispose();
    };
  });
</script>

<audio class="hidden" bind:this={nativePlayer}></audio>
