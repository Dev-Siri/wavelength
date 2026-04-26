<script>
  import {
    PauseIcon,
    PlayIcon,
    SkipBackIcon,
    SkipForwardIcon,
  } from "@lucide/svelte";

  import MusicPlayerProgressBar from "./MusicPlayerProgressBar.svelte";
  import * as Tooltip from "./ui/tooltip";

  let isPlaying = $state(true);
</script>

<div id="player-controls" class="flex w-full flex-col">
  <MusicPlayerProgressBar />
  <div class="flex gap-10 items-center justify-center w-full">
    <Tooltip.Root>
      <Tooltip.Trigger class="scale-125 cursor-pointer">
        <SkipBackIcon fill="white" font-weight="normal" size={16} />
      </Tooltip.Trigger>
      <Tooltip.Content class="z-99999">
        <p>Previous</p>
      </Tooltip.Content>
    </Tooltip.Root>
    <Tooltip.Root>
      <Tooltip.Trigger
        onclick={() => (isPlaying = !isPlaying)}
        class="scale-125 cursor-pointer bg-white rounded-full p-2"
      >
        {#if isPlaying}
          <PauseIcon color="transparent" fill="black" size={20} />
        {:else}
          <PlayIcon color="transparent" fill="black" size={20} />
        {/if}
      </Tooltip.Trigger>
      <Tooltip.Content>
        <p>Play</p>
      </Tooltip.Content>
    </Tooltip.Root>
    <Tooltip.Root>
      <Tooltip.Trigger class="scale-125 cursor-pointer">
        <SkipForwardIcon fill="white" font-weight="normal" size={16} />
      </Tooltip.Trigger>
      <Tooltip.Content class="z-99999">
        <p>Next</p>
      </Tooltip.Content>
    </Tooltip.Root>
  </div>
</div>
