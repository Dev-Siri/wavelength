<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";

  let musicPlayerElement: HTMLAudioElement;

  function handlePlayerEnd() {
    if (musicPlayerStore.repeatMode === "one") return musicPlayerStore.playMusic();

    if (!musicQueueStore.musicPlayingNow) return;

    musicPlayerStore.isPlaying = false;

    const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    const wasSongTheLastInQueue = musicQueueStore.musicQueue.length - 1 === songThatWasPlayedIndex;

    let nextIndex = 0;

    if (wasSongTheLastInQueue) {
      nextIndex = 0;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    if (musicPlayerStore.repeatMode === "all" || !wasSongTheLastInQueue)
      musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
  }

  $effect(() => {
    musicPlayerStore.musicPlayer = musicPlayerElement;

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if (musicPlayerStore.isPlaying) {
        musicPlayerElement.pause();
      } else {
        musicPlayerElement.play();
      }
    }

    window.addEventListener("keypress", musicPlayerShortcuts);

    return () => window.removeEventListener("keypress", musicPlayerShortcuts);
  });

  $effect(() => {
    if (musicQueueStore.musicPlayingNow) 
      musicPlayerStore.loadTrack(musicQueueStore.musicPlayingNow.videoId);
  });
</script>

<div class="flex bg-black h-full w-full pl-3">
  <audio
    autoplay
    bind:this={musicPlayerElement}
    class="hidden"
    src={musicPlayerStore.source}
    bind:muted={musicPlayerStore.isMuted}
    onpause={() => (musicPlayerStore.isPlaying = false)}
    onplay={() => (musicPlayerStore.isPlaying = true)}
    oncanplaythrough={musicPlayerStore.playMusic}
    onended={handlePlayerEnd}
    ondurationchange={({ currentTarget: { duration } }) => (musicPlayerStore.duration = duration)}
    ontimeupdate={({ currentTarget: { currentTime } }) =>
      (musicPlayerStore.currentTime = currentTime)}
    bind:volume={musicPlayerStore.volume}
  ></audio>
  <section class="flex h-full w-1/3 items-center">
    <MusicPlayerTrackLabel />
  </section>
  <section class="flex flex-col gap-2 h-full w-1/3">
    <MusicPlayerControls />
  </section>
  <section class="flex items-center justify-end pr-10 h-full gap-1 w-1/3 md:pl-[10%]">
    <PlaybackOptions />
  </section>
</div>
