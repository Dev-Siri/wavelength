<script lang="ts">
  import { Volume2Icon, VolumeOffIcon } from "@lucide/svelte";

  import { localStorageKeys } from "$lib/constants/keys.js";
  import musicPlayerStore from "$lib/stores/music-player.svelte.js";

  import { Button } from "./ui/button";
  import { Slider } from "./ui/slider";

  $effect(() => {
    const storedVolume = localStorage.getItem(localStorageKeys.volume);

    if (storedVolume) {
      const numericalVolume = Number(storedVolume);
      musicPlayerStore.setVolume(numericalVolume > 1 ? 1 : numericalVolume);
    }
  });

  $effect(() => {
    musicPlayerStore.setVolume(musicPlayerStore.volume);
    localStorage.setItem(localStorageKeys.volume, musicPlayerStore.volume.toString());
  });
</script>

<div class="items-center w-fit md:w-full gap-2 justify-center hidden sm:flex">
  <Button
    variant="ghost"
    class="px-3 rounded-full select-none outline-hidden"
    onclick={musicPlayerStore.isMuted ? musicPlayerStore.unmute : musicPlayerStore.mute}
  >
    {#if musicPlayerStore.isMuted}
      <VolumeOffIcon size={20} />
    {:else}
      <Volume2Icon size={20} />
    {/if}
  </Button>
  <Slider
    type="single"
    bind:value={musicPlayerStore.volume}
    class="h-2 w-20 hidden md:flex"
    step={0.01}
    min={0}
    max={1}
  />
</div>
