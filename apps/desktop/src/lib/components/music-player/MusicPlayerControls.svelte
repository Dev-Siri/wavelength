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

  import { musicPlayer } from "$lib/stream-player/musicPlayer";

  import { buttonVariants } from "../ui/button";
  import * as Tooltip from "../ui/tooltip";
  import MusicPlayerProgressBar from "./MusicPlayerProgressBar.svelte";
</script>

<div class="flex w-full gap-3 items-center justify-center">
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({ variant: "ghost", size: "icon", class: "rounded-full" })}
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
            size={22}
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
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({ variant: "ghost", size: "icon", class: "rounded-full" })}
      disabled={!musicPlayer.queue.playingNow}
      onclick={() => musicPlayer.previous()}
    >
      <SkipBackIcon fill="white" font-weight="normal" size={24} />
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>Previous</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({ size: "icon", class: "rounded-full" })}
      disabled={!musicPlayer.queue.playingNow}
      onclick={() => (musicPlayer.isPlaying ? musicPlayer.pause() : musicPlayer.play())}
    >
      {#if musicPlayer.isPlaying}
        <PauseIcon color="transparent" fill="black" class="rounded-full" size={28} />
      {:else}
        <PlayIcon color="transparent" fill="black" class="rounded-full" size={28} />
      {/if}
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>{musicPlayer.isPlaying ? "Pause" : "Play"}</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({ size: "icon", variant: "ghost", class: "rounded-full" })}
      disabled={!musicPlayer.queue.playingNow}
      onclick={() => musicPlayer.next()}
    >
      <SkipForwardIcon fill="white" font-weight="normal" size={24} />
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>Next</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({ variant: "ghost", size: "icon", class: "rounded-full" })}
      onclick={() => musicPlayer.queue.cycleRepeatMode()}
    >
      {#if musicPlayer.queue.repeatMode === "none"}
        <div in:scale>
          <RepeatIcon opacity={0.4} font-weight="normal" size={22} />
        </div>
      {:else if musicPlayer.queue.repeatMode === "all"}
        <div in:scale>
          <RepeatIcon fill="white" font-weight="normal" size={22} />
        </div>
      {:else}
        <div in:scale>
          <Repeat1Icon fill="white" font-weight="normal" size={22} />
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
