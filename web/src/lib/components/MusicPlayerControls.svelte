<script lang="ts">
  import { FastForward, Pause, Play, Repeat, Repeat1, Rewind } from "lucide-svelte";
  import { fade } from "svelte/transition";

  import { isMusicPlaying, musicRepeatMode, pauseMusic, playMusic } from "$lib/stores/music-player";
  import { musicPlayingNow, musicQueue } from "$lib/stores/music-queue";

  import ProgressBar from "./ProgressBar.svelte";
  import { Button } from "./ui/button";
  import * as Tooltip from "./ui/tooltip";

  function changeMusicRepeatMode() {
    if ($musicRepeatMode === "none") {
      $musicRepeatMode = "all";
    } else if ($musicRepeatMode === "all") {
      $musicRepeatMode = "one";
    } else {
      $musicRepeatMode = "none";
    }
  }

  function playNextSong() {
    if (!$musicPlayingNow) return;

    const songThatWasPlayedIndex = $musicQueue.findIndex(
      track => $musicPlayingNow.title === track.title,
    );

    let nextIndex = 0;

    if ($musicQueue.length - 1 === songThatWasPlayedIndex) {
      if ($musicRepeatMode === "all") nextIndex = 0;
      else return;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    musicPlayingNow.set($musicQueue[nextIndex]);
    playMusic();
  }

  function playPreviousSong() {
    if (!$musicPlayingNow) return;

    const songThatWasPlayedIndex = $musicQueue.findIndex(
      track => $musicPlayingNow.title === track.title,
    );

    let prevIndex = 0;

    if (songThatWasPlayedIndex === 0) {
      if ($musicRepeatMode === "all") prevIndex = $musicQueue.length - 1;
      else return;
    } else {
      prevIndex = songThatWasPlayedIndex - 1;
    }

    musicPlayingNow.set($musicQueue[prevIndex]);
    playMusic();
  }
</script>

<div class="flex w-full gap-3 items-center justify-center mt-4 pl-12">
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-2"
        disabled={!$musicPlayingNow}
        variant="ghost"
        on:click={playPreviousSong}
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
        disabled={!$musicPlayingNow}
        on:click={$isMusicPlaying ? pauseMusic : playMusic}
      >
        {#if $isMusicPlaying}
          <Pause fill="black" size={20} font-weight="normal" />
        {:else}
          <Play fill="black" size={20} font-weight="normal" />
        {/if}
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content>
      <p>{$isMusicPlaying ? "Pause" : "Play"}</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-2"
        disabled={!$musicPlayingNow}
        variant="ghost"
        on:click={playNextSong}
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
      <Button class="rounded-full h-10 w-10 p-2" variant="ghost" on:click={changeMusicRepeatMode}>
        {#if $musicRepeatMode === "none"}
          <div in:fade>
            <Repeat opacity={0.4} font-weight="normal" size={22} />
          </div>
        {:else if $musicRepeatMode === "all"}
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
      {#if $musicRepeatMode === "none"}
        <p>Enable Repeat All</p>
      {:else if $musicRepeatMode === "all"}
        <p>Enable Repeat One</p>
      {:else}
        <p>Disable Repeat</p>
      {/if}
    </Tooltip.Content>
  </Tooltip.Root>
</div>
<ProgressBar />
