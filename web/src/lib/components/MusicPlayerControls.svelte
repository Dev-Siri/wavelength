<script lang="ts">
  import { FastForward, Pause, Play, Repeat, Repeat1, Rewind } from "lucide-svelte";
  import { fade } from "svelte/transition";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import ProgressBar from "./ProgressBar.svelte";
  import { Button } from "./ui/button";
  import * as Tooltip from "./ui/tooltip";

  function changeMusicRepeatMode() {
    if (musicPlayerStore.musicRepeatMode === "none") {
      musicPlayerStore.musicRepeatMode = "all";
    } else if (musicPlayerStore.musicRepeatMode === "all") {
      musicPlayerStore.musicRepeatMode = "one";
    } else {
      musicPlayerStore.musicRepeatMode = "none";
    }
  }

  function playNextSong() {
    if (!musicQueueStore.musicPlayingNow) return;

    const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    let nextIndex = 0;

    if (musicQueueStore.musicQueue.length - 1 === songThatWasPlayedIndex) {
      if (musicPlayerStore.musicRepeatMode === "all") nextIndex = 0;
      else return;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
    musicPlayerStore.playMusic();
  }

  function playPreviousSong() {
    if (!musicQueueStore.musicPlayingNow) return;

    const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    let prevIndex = 0;

    if (songThatWasPlayedIndex === 0) {
      if (musicPlayerStore.musicRepeatMode === "all")
        prevIndex = musicQueueStore.musicQueue.length - 1;
      else return;
    } else {
      prevIndex = songThatWasPlayedIndex - 1;
    }

    musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[prevIndex];
    musicPlayerStore.playMusic();
  }
</script>

<div class="flex w-full gap-3 items-center justify-center mt-4 pl-12">
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-2"
        disabled={!musicQueueStore.musicPlayingNow}
        variant="ghost"
        onclick={playPreviousSong}
      >
        <Rewind fill="white" font-weight="normal" size={24} />
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content>
      <p>Previous</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-1"
        disabled={!musicQueueStore.musicPlayingNow}
        onclick={musicPlayerStore.isMusicPlaying
          ? musicPlayerStore.pauseMusic
          : musicPlayerStore.playMusic}
      >
        {#if musicPlayerStore.isMusicPlaying}
          <Pause fill="black" size={20} font-weight="normal" />
        {:else}
          <Play fill="black" size={20} font-weight="normal" />
        {/if}
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content>
      <p>{musicPlayerStore.isMusicPlaying ? "Pause" : "Play"}</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-2"
        disabled={!musicQueueStore.musicPlayingNow}
        variant="ghost"
        onclick={playNextSong}
      >
        <FastForward fill="white" font-weight="normal" size={24} />
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content>
      <p>Next</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button class="rounded-full h-10 w-10 p-2" variant="ghost" onclick={changeMusicRepeatMode}>
        {#if musicPlayerStore.musicRepeatMode === "none"}
          <div in:fade>
            <Repeat opacity={0.4} font-weight="normal" size={22} />
          </div>
        {:else if musicPlayerStore.musicRepeatMode === "all"}
          <div in:fade>
            <Repeat fill="white" font-weight="normal" size={22} />
          </div>
        {:else}
          <div in:fade>
            <Repeat1 fill="white" font-weight="normal" size={22} />
          </div>
        {/if}
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content>
      {#if musicPlayerStore.musicRepeatMode === "none"}
        <p>Enable Repeat All</p>
      {:else if musicPlayerStore.musicRepeatMode === "all"}
        <p>Enable Repeat One</p>
      {:else}
        <p>Disable Repeat</p>
      {/if}
    </Tooltip.Content>
  </Tooltip.Root>
</div>
<ProgressBar />
