<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { getStreamUrl, getThumbnailUrl } from "$lib/utils/url";

  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";

  let musicPlayerElement: HTMLAudioElement;

  function handlePlayerEnd() {
    if (musicPlayerStore.musicRepeatMode === "one") return musicPlayerStore.playMusic();

    if (!musicQueueStore.musicPlayingNow) return;

    musicPlayerStore.isMusicPlaying = false;

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

    if (musicPlayerStore.musicRepeatMode === "all" || !wasSongTheLastInQueue)
      musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
  }

  $effect(() => {
    musicPlayerStore.musicPlayer = musicPlayerElement;

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if (musicPlayerStore.isMusicPlaying) {
        musicPlayerElement.pause();
      } else {
        musicPlayerElement.play();
      }
    }

    window.addEventListener("keypress", musicPlayerShortcuts);

    return () => window.removeEventListener("keypress", musicPlayerShortcuts);
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicQueueStore.musicPlayingNow) return (navigator.mediaSession.metadata = null);

      musicPlayerStore.musicCurrentTime = 0;

      musicPlayerStore.musicSource = getStreamUrl(musicQueueStore.musicPlayingNow.videoId, "audio");

      await musicPlayerStore.playMusic();

      if ("mediaSession" in navigator)
        navigator.mediaSession.metadata = new MediaMetadata({
          title: musicQueueStore.musicPlayingNow.title,
          artist: musicQueueStore.musicPlayingNow.author,
          artwork: [
            {
              src: getThumbnailUrl(musicQueueStore.musicPlayingNow.videoId),
              sizes: "256x256",
              type: "image/jpeg",
            },
          ],
        });
    }

    handleMusicPlayingNowChange();
  });
</script>

<div class="flex bg-black h-full w-full pl-3">
  <audio
    autoplay
    bind:this={musicPlayerElement}
    class="hidden"
    src={musicPlayerStore.musicSource}
    bind:muted={musicPlayerStore.isMusicMuted}
    onpause={() => (musicPlayerStore.isMusicPlaying = false)}
    onplay={() => (musicPlayerStore.isMusicPlaying = true)}
    onended={handlePlayerEnd}
    ondurationchange={({ currentTarget: { duration } }) =>
      (musicPlayerStore.musicDuration = duration)}
    ontimeupdate={({ currentTarget: { currentTime } }) =>
      (musicPlayerStore.musicCurrentTime = currentTime)}
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
