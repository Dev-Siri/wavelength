<script lang="ts">
  import createYouTubePlayer from "youtube-player";

  import { musicPlayerStates } from "$lib/constants/music-player";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";

  let musicPlayerElement: HTMLDivElement;

  async function trackProgress() {
    if (!musicPlayerStore.musicPlayer || !musicPlayerStore.isPlaying) return;

    const [currentTime, duration] = await Promise.all([
      musicPlayerStore.musicPlayer.getCurrentTime(),
      musicPlayerStore.musicPlayer.getDuration(),
    ]);

    if (duration > 0) {
      const progress = (currentTime / duration) * 100;

      musicPlayerStore.progress = progress;
    }
  }

  async function onStateChange(event: any) {
    const playerState = event.data;

    switch (playerState) {
      // Extra handlers to sync the state with the player
      // In case a non-application event causes the video's state to change.
      case musicPlayerStates.playing:
        musicPlayerStore.duration = (await musicPlayerStore.musicPlayer?.getDuration()) ?? 0;
        musicPlayerStore.isPlaying = true;
        break;
      case musicPlayerStates.paused:
        musicPlayerStore.isPlaying = false;
        break;
      case musicPlayerStates.ended:
        if (musicPlayerStore.repeatMode === "one") {
          musicPlayerStore.playMusic();
          break;
        }

        if (!musicQueueStore.musicPlayingNow) break;

        musicPlayerStore.isPlaying = false;

        const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
          track => musicQueueStore.musicPlayingNow?.title === track.title,
        );
        const wasSongTheLastInQueue =
          musicQueueStore.musicQueue.length - 1 === songThatWasPlayedIndex;

        let nextIndex = 0;

        if (wasSongTheLastInQueue) {
          nextIndex = 0;
        } else {
          nextIndex = songThatWasPlayedIndex + 1;
        }

        if (musicPlayerStore.repeatMode === "all" || !wasSongTheLastInQueue)
          musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
    }
  }

  $effect(() => {
    const youtubePlayer = createYouTubePlayer(musicPlayerElement, {
      playerVars: {
        autoplay: 0,
        controls: 0,
        disablekb: 1,
        playsinline: 1,
      },
    });

    musicPlayerStore.musicPlayer = youtubePlayer;

    const interval = setInterval(trackProgress, 250);

    youtubePlayer.on("stateChange", onStateChange);

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
      clearInterval(interval);
      youtubePlayer.destroy();
    };
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicPlayerStore.musicPlayer || !musicQueueStore.musicPlayingNow) return;

      musicPlayerStore.progress = 0;

      await musicPlayerStore.musicPlayer.loadVideoById(musicQueueStore.musicPlayingNow.videoId);

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

<div class="flex bg-black h-full w-full pl-3">
  <div class="hidden" bind:this={musicPlayerElement}></div>
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
