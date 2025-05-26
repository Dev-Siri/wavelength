<script lang="ts">
  import { Volume2, VolumeOff } from "lucide-svelte";

  import { localStorageKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";

  import { Button } from "./ui/button";
  import { Slider } from "./ui/slider";

  let volume = $state(100);

  $effect(() => {
    const storedVolume = localStorage.getItem(localStorageKeys.volume);

    if (storedVolume) volume = Number(storedVolume);
  });

  $effect(() => {
    musicPlayerStore.musicPlayer?.setVolume(volume);
    localStorage.setItem(localStorageKeys.volume, volume.toString());
  });
</script>

<div class="items-center w-fit md:w-full gap-2 justify-center hidden sm:flex">
  <Button
    variant="ghost"
    class="px-3 rounded-full select-none outline-hidden"
    onclick={() => (musicPlayerStore.isMusicMuted = !musicPlayerStore.isMusicMuted)}
  >
    {#if musicPlayerStore.isMusicMuted}
      <VolumeOff size={20} />
    {:else}
      <Volume2 size={20} />
    {/if}
  </Button>
  <Slider type="single" bind:value={volume} class="h-2 w-20 hidden md:flex" min={0} max={100} />
</div>
