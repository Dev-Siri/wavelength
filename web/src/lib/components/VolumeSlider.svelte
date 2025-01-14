<script lang="ts">
  import { Volume2, VolumeOff } from "lucide-svelte";

  import { isMusicMuted, musicPlayer } from "$lib/stores/music-player";

  import { Button } from "./ui/button";
  import { Slider } from "./ui/slider";

  let bindedVolume: number[] = [100];

  $: volume = (bindedVolume ? bindedVolume[0] : 100) ?? 100;

  $: $musicPlayer?.setVolume(volume);
</script>

<div class="flex items-center gap-2 justify-center">
  <Button
    variant="ghost"
    class="px-2.5 rounded-full select-none outline-none"
    on:click={() => ($isMusicMuted = !$isMusicMuted)}
  >
    {#if $isMusicMuted}
      <VolumeOff size={20} />
    {:else}
      <Volume2 size={20} />
    {/if}
  </Button>
  <Slider bind:value={bindedVolume} class="h-2 w-20" />
</div>
