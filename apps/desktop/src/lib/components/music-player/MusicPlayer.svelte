<script lang="ts">
  import type { PlayerEvent } from "$lib/stream-player/player";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import { WebEmbedPlayer } from "$lib/stream-player/web-embed";
  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerPlaybackOptions from "./MusicPlayerPlaybackOptions.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";

  let musicPlayerElement: HTMLDivElement;

  // Extra handlers to sync the state with the player
  // In case a non-application event causes the video's state to change.
  async function handleOnPlay() {
    musicPlayerStore.duration = (await musicPlayerStore.musicPlayer?.getDuration()) ?? 0;
    musicPlayerStore.isPlaying = true;
  }

  const handleOnPause = () => (musicPlayerStore.isPlaying = false);

  async function handleOnEnded() {
    if (musicPlayerStore.repeatMode === "one") {
      musicPlayerStore.playMusic();
      return;
    }

    if (!musicQueueStore.musicPlayingNow) return;

    musicPlayerStore.isPlaying = false;

    const songThatWasPlayedIndex = musicQueueStore.musicPlaylistContext.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );
    const wasSongTheLastInQueue =
      musicQueueStore.musicPlaylistContext.length - 1 === songThatWasPlayedIndex;

    let nextIndex = 0;

    if (wasSongTheLastInQueue) {
      nextIndex = 0;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    if (musicPlayerStore.repeatMode === "all" || !wasSongTheLastInQueue)
      musicQueueStore.musicPlayingNow = musicQueueStore.musicPlaylistContext[nextIndex];
  }

  async function handleTimeUpdate(event: PlayerEvent<"timeupdate">) {
    if (!musicPlayerStore.musicPlayer || !musicPlayerStore.isPlaying) return;
    const { duration, currentTime } = event.detail;

    if (duration > 0) {
      const progress = (currentTime / duration) * 100;

      musicPlayerStore.progress = progress;
    }
  }

  $effect(() => {
    const youtubePlayer = new WebEmbedPlayer(musicPlayerElement, {
      playerVars: {
        autoplay: 0,
        controls: 0,
        disablekb: 1,
        playsinline: 1,
      },
    });

    musicPlayerStore.musicPlayer = youtubePlayer;

    youtubePlayer.on("playing", handleOnPlay);
    youtubePlayer.on("paused", handleOnPause);
    youtubePlayer.on("ended", handleOnEnded);
    youtubePlayer.on("timeupdate", handleTimeUpdate);

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if (musicPlayerStore.isPlaying) {
        musicPlayerStore.pauseMusic();
      } else {
        musicPlayerStore.playMusic();
      }
    }

    window.addEventListener("keypress", musicPlayerShortcuts);
    return () => {
      window.removeEventListener("keypress", musicPlayerShortcuts);
      youtubePlayer.dispose();
    };
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicPlayerStore.musicPlayer || !musicQueueStore.musicPlayingNow) return;

      musicPlayerStore.progress = 0;
      await musicPlayerStore.musicPlayer.load(musicQueueStore.musicPlayingNow.videoId);
      musicPlayerStore.isPlaying = true;
    }

    handleMusicPlayingNowChange();
  });

  $effect(() => {
    if (musicPlayerStore.isMuted) {
      musicPlayerStore.musicPlayer?.mute();
    } else {
      musicPlayerStore.musicPlayer?.unMute();
    }
  });
</script>

<div class="flex bg-black/35 backdrop-blur-xl backdrop-saturate-150 h-full w-full pl-2">
  <div class="hidden" bind:this={musicPlayerElement}></div>
  <section class="flex h-full w-1/3 items-center">
    <MusicPlayerTrackLabel />
  </section>
  <section class="flex flex-col gap-2 h-full w-1/3">
    <MusicPlayerControls />
  </section>
  <section class="flex items-center justify-end pr-10 h-full gap-1 w-1/3 md:pl-[10%]">
    <MusicPlayerPlaybackOptions />
  </section>
</div>
