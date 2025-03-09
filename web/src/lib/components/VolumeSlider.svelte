<script lang="ts">
  import { Volume2, VolumeOff } from "lucide-svelte";

  import { isMusicMuted, musicPlayer } from "$lib/stores/music-player";

  import { Button } from "./ui/button";
  import { Slider } from "./ui/slider";

  let volume = $state(100);

  $effect(() => {
    $musicPlayer?.setVolume(volume);
  });
</script>

<div class="flex items-center w-full gap-2 justify-center">
  <Button
    variant="ghost"
    class="px-3 rounded-full select-none outline-hidden"
    onclick={() => ($isMusicMuted = !$isMusicMuted)}
  >
    {#if $isMusicMuted}
      <VolumeOff size={20} />
    {:else}
      <Volume2 size={20} />
    {/if}
  </Button>
  <Slider type="single" bind:value={volume} class="h-2 w-20" min={0} max={100} />
</div>
