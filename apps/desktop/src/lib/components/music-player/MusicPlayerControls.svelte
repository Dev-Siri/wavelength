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

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { shuffle } from "$lib/utils/shuffle";

  import { Button } from "../ui/button";
  import * as Tooltip from "../ui/tooltip";
  import ProgressBar from "./MusicPlayerProgressBar.svelte";

  function changeMusicRepeatMode() {
    if (musicPlayerStore.repeatMode === "none") {
      musicPlayerStore.repeatMode = "all";
    } else if (musicPlayerStore.repeatMode === "all") {
      musicPlayerStore.repeatMode = "one";
    } else {
      musicPlayerStore.repeatMode = "none";
    }
  }

  function playNextSong() {
    if (!musicQueueStore.musicPlayingNow) return;

    const songThatWasPlayedIndex = musicQueueStore.musicPlaylistContext.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    let nextIndex = 0;

    if (musicQueueStore.musicPlaylistContext.length - 1 === songThatWasPlayedIndex) {
      if (musicPlayerStore.repeatMode === "all") {
        nextIndex = 0;
        musicQueueStore.musicPlaylistContext = shuffle(musicQueueStore.musicPlaylistContext);
      } else return;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    musicQueueStore.musicPlayingNow = musicQueueStore.musicPlaylistContext[nextIndex];
    musicPlayerStore.playMusic();
  }

  function playPreviousSong() {
    if (!musicQueueStore.musicPlayingNow) return;

    const songThatWasPlayedIndex = musicQueueStore.musicPlaylistContext.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    let prevIndex = 0;

    if (songThatWasPlayedIndex === 0) {
      if (musicPlayerStore.repeatMode === "all")
        prevIndex = musicQueueStore.musicPlaylistContext.length - 1;
      else return;
    } else {
      prevIndex = songThatWasPlayedIndex - 1;
    }

    musicQueueStore.musicPlayingNow = musicQueueStore.musicPlaylistContext[prevIndex];
    musicPlayerStore.playMusic();
  }

  function changeShuffleMode() {
    musicPlayerStore.isShuffleModeOn = !musicPlayerStore.isShuffleModeOn;
    if (musicPlayerStore.isShuffleModeOn) {
      musicQueueStore.musicPlaylistContextPreshuffle = musicQueueStore.musicPlaylistContext;
      musicQueueStore.musicPlaylistContext = shuffle(musicQueueStore.musicPlaylistContext);
    } else {
      musicQueueStore.musicPlaylistContext = musicQueueStore.musicPlaylistContextPreshuffle;
      musicQueueStore.musicPlaylistContextPreshuffle = [];
    }
  }
</script>

<div class="flex w-full gap-3 items-center justify-center mt-4">
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button class="rounded-full h-10 w-10 p-2" variant="ghost" onclick={changeShuffleMode}>
        {#key musicPlayerStore.isShuffleModeOn}
          <div in:scale>
            <ShuffleIcon
              fill="white"
              font-weight="normal"
              size={22}
              opacity={musicPlayerStore.isShuffleModeOn ? 1 : 0.4}
            />
          </div>
        {/key}
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>
        {musicPlayerStore.isShuffleModeOn ? "Disable" : "Enable"} shuffle
      </p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-2"
        disabled={!musicQueueStore.musicPlayingNow}
        variant="ghost"
        onclick={playPreviousSong}
      >
        <SkipBackIcon fill="white" font-weight="normal" size={24} />
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>Previous</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button
        class="rounded-full h-10 w-10 p-1"
        disabled={!musicQueueStore.musicPlayingNow}
        onclick={musicPlayerStore.isPlaying
          ? musicPlayerStore.pauseMusic
          : musicPlayerStore.playMusic}
      >
        {#if musicPlayerStore.isPlaying}
          <PauseIcon fill="black" size={20} />
        {:else}
          <PlayIcon fill="black" size={20} />
        {/if}
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>{musicPlayerStore.isPlaying ? "Pause" : "Play"}</p>
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
        <SkipForwardIcon fill="white" font-weight="normal" size={24} />
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      <p>Next</p>
    </Tooltip.Content>
  </Tooltip.Root>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <Button class="rounded-full h-10 w-10 p-2" variant="ghost" onclick={changeMusicRepeatMode}>
        {#if musicPlayerStore.repeatMode === "none"}
          <div in:scale>
            <RepeatIcon opacity={0.4} font-weight="normal" size={22} />
          </div>
        {:else if musicPlayerStore.repeatMode === "all"}
          <div in:scale>
            <RepeatIcon fill="white" font-weight="normal" size={22} />
          </div>
        {:else}
          <div in:scale>
            <Repeat1Icon fill="white" font-weight="normal" size={22} />
          </div>
        {/if}
      </Button>
    </Tooltip.Trigger>
    <Tooltip.Content class="z-99999">
      {#if musicPlayerStore.repeatMode === "none"}
        <p>Enable Repeat All</p>
      {:else if musicPlayerStore.repeatMode === "all"}
        <p>Enable Repeat One</p>
      {:else}
        <p>Disable Repeat</p>
      {/if}
    </Tooltip.Content>
  </Tooltip.Root>
</div>
<ProgressBar />
