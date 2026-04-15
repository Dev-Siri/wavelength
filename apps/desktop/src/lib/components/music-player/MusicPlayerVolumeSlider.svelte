<script lang="ts">
  import { Volume2Icon, VolumeOffIcon } from "@lucide/svelte";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  import { buttonVariants } from "../ui/button";
  import { Slider } from "../ui/slider";
  import * as Tooltip from "../ui/tooltip";

  $effect(() => {
    musicPlayer.setVolume(musicPlayer.volume);
  });
</script>

<div class="items-center w-fit md:w-full gap-2 justify-center hidden sm:flex">
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({
        variant: "ghost",
        class: "px-3 rounded-full select-none outline-hidden",
      })}
      onclick={() => musicPlayer.toggleMute()}
    >
      {#if musicPlayer.isMuted}
        <VolumeOffIcon size={20} />
      {:else}
        <Volume2Icon size={20} />
      {/if}
    </Tooltip.Trigger>
    <Tooltip.Content class="z-9999">
      <p>{musicPlayer.isMuted ? "Unmute" : "Mute"}</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Slider
    type="single"
    bind:value={musicPlayer.volume}
    class="h-2 w-20 hidden md:flex"
    step={0.01}
    min={0}
    max={1}
  />
</div>
