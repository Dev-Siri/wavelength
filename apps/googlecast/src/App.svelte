<script lang="ts">
  import { onDestroy } from "svelte";
  import { fade } from "svelte/transition";

  import { googleCast } from "./lib/googleCast.svelte";

  import MusicPlayer from "./lib/components/MusicPlayer.svelte";
  import TooltipProvider from "./lib/components/ui/tooltip/tooltip-provider.svelte";

  onDestroy(() => {
    googleCast.dispose();
  });
</script>

<TooltipProvider>
  <div id="app-shell" class="h-screen w-screen select-none pt-12 px-12">
    <main class="h-full w-full">
      {#if googleCast.track}
        <MusicPlayer />
      {:else}
        <div in:fade class="h-full w-full grid place-items-center">
          <p class="text-8xl font-black">λ</p>
        </div>
      {/if}
    </main>
  </div>
</TooltipProvider>
