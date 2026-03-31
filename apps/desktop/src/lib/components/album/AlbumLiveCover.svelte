<script lang="ts">
  import Hls from "hls.js";
  import { blur } from "svelte/transition";

  let liveCoverPlayer: HTMLVideoElement;

  const { liveCoverUri, height, width }: { liveCoverUri: string; height?: number; width?: number } =
    $props();

  $effect(() => {
    let hls: Hls | null;

    if (liveCoverPlayer.canPlayType("application/vnd.apple.mpegurl")) {
      liveCoverPlayer.src = liveCoverUri;
    } else if (Hls.isSupported()) {
      hls = new Hls();
      hls.loadSource(liveCoverUri);
      hls.attachMedia(liveCoverPlayer);
    }

    return () => hls?.destroy();
  });
</script>

<video
  autoplay
  loop
  playsinline
  class="aspect-square object-cover h-full w-full z-10"
  in:blur
  {height}
  {width}
  bind:this={liveCoverPlayer}
>
  <track kind="captions" />
</video>
