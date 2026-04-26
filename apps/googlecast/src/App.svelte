<script lang="ts">
  import { onMount } from "svelte";

  import { setApplicationCastContext } from "./lib/context/googleCastContext";
  import GoogleCast from "./lib/googleCast.svelte";

  import MusicPlayer from "./lib/components/MusicPlayer.svelte";
  import TooltipProvider from "./lib/components/ui/tooltip/tooltip-provider.svelte";

  let audioPlayer: HTMLAudioElement;

  setApplicationCastContext(null);

  onMount(() => {
    const googleCast = new GoogleCast(audioPlayer);

    setApplicationCastContext(googleCast);
    return () => googleCast.dispose();
  });
</script>

<TooltipProvider>
  <div id="app-shell" class="h-screen w-screen select-none pt-12 px-12">
    <audio
      class="hidden"
      id="wavlen-tv-streaming-device"
      bind:this={audioPlayer}
    ></audio>
    <main class="h-full w-full">
      <MusicPlayer />
    </main>
  </div>
</TooltipProvider>
