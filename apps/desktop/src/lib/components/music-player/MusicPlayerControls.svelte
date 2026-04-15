<script lang="ts">
  import {
    PauseIcon,
    PlayIcon,
    Repeat1Icon,
    RepeatIcon,
    ShuffleIcon,
    SkipBackIcon,
    SkipForwardIcon,
  } from "@lucide/svelte";
  import { scale } from "svelte/transition";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  import * as Tooltip from "../ui/tooltip";
  import MusicPlayerProgressBar from "./MusicPlayerProgressBar.svelte";
</script>

<div class="flex w-full gap-8 items-center justify-center">
  <Tooltip.Root>
    <Tooltip.Trigger
      class="cursor-pointer"
      onclick={() =>
        musicPlayer.queue.shuffleEnabled
          ? musicPlayer.queue.disableShuffle()
          : musicPlayer.queue.enableShuffle()}
    >
      {#key musicPlayer.queue.shuffleEnabled}
        <div in:scale>
          <ShuffleIcon
            fill="white"
            font-weight="normal"
            size={16}
            opacity={musicPlayer.queue.shuffleEnabled ? 1 : 0.4}
          />
        </div>
      {/key}
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>
        {musicPlayer.queue.shuffleEnabled ? "Disable" : "Enable"} Shuffle
      </p>
    </Tooltip.Content>
  </Tooltip.Root>
  <div class="flex gap-6 items-center">
    <Tooltip.Root>
      <Tooltip.Trigger
        class="cursor-pointer"
        disabled={!musicPlayer.queue.playingNow}
        onclick={() => musicPlayer.previous()}
      >
        <SkipBackIcon fill="white" font-weight="normal" size={16} />
      </Tooltip.Trigger>
      <Tooltip.Content class="z-99999">
        <p>Previous</p>
      </Tooltip.Content>
    </Tooltip.Root>
    <Tooltip.Root>
      <Tooltip.Trigger
        class="cursor-pointer bg-white rounded-full p-2"
        disabled={!musicPlayer.queue.playingNow}
        onclick={() => (musicPlayer.isPlaying ? musicPlayer.pause() : musicPlayer.play())}
      >
        {#if musicPlayer.isPlaying}
          <PauseIcon color="transparent" fill="black" size={20} />
        {:else}
          <PlayIcon color="transparent" fill="black" size={20} />
        {/if}
      </Tooltip.Trigger>
      <Tooltip.Content class="z-99999">
        <p>{musicPlayer.isPlaying ? "Pause" : "Play"}</p>
      </Tooltip.Content>
    </Tooltip.Root>
    <Tooltip.Root>
      <Tooltip.Trigger
        class="cursor-pointer"
        disabled={!musicPlayer.queue.playingNow}
        onclick={() => musicPlayer.next()}
      >
        <SkipForwardIcon fill="white" font-weight="normal" size={16} />
      </Tooltip.Trigger>
      <Tooltip.Content class="z-99999">
        <p>Next</p>
      </Tooltip.Content>
    </Tooltip.Root>
  </div>
  <Tooltip.Root>
    <Tooltip.Trigger class="cursor-pointer" onclick={() => musicPlayer.queue.cycleRepeatMode()}>
      {#if musicPlayer.queue.repeatMode === "none"}
        <div in:scale>
          <RepeatIcon opacity={0.4} font-weight="normal" size={16} />
        </div>
      {:else if musicPlayer.queue.repeatMode === "all"}
        <div in:scale>
          <RepeatIcon fill="white" font-weight="normal" size={16} />
        </div>
      {:else}
        <div in:scale>
          <Repeat1Icon fill="white" font-weight="normal" size={16} />
        </div>
      {/if}
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      {#if musicPlayer.queue.repeatMode === "none"}
        <p>Enable Repeat All</p>
      {:else if musicPlayer.queue.repeatMode === "all"}
        <p>Enable Repeat One</p>
      {:else}
        <p>Disable Repeat</p>
      {/if}
    </Tooltip.Content>
  </Tooltip.Root>
</div>
<MusicPlayerProgressBar />
