<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";

  import type { PlayerEvent, StreamPlayer } from "$lib/stream-player/player";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { NativePlayer } from "$lib/stream-player/native-player";
  import { WebEmbedPlayer } from "$lib/stream-player/web-embed";
  import { punctuatify } from "$lib/utils/format";

  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerPlaybackOptions from "./MusicPlayerPlaybackOptions.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";

  let webEmbedPlayer: HTMLDivElement | null = $state(null);
  let nativePlayer: HTMLAudioElement | null = $state(null);

  // Extra handlers to sync the state with the player
  // In case a non-application event causes the video's state to change.
  async function handleOnPlay() {
    musicPlayerStore.duration = (await musicPlayerStore.musicPlayer?.getDuration()) ?? 0;
    musicPlayerStore.isPlaying = true;
  }

  const handleOnPause = () => (musicPlayerStore.isPlaying = false);

  async function handleOnEnded() {
    if (musicPlayerStore.repeatMode === "one") return musicPlayerStore.playMusic();

    musicPlayerStore.currentTime = 0;
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

    musicPlayerStore.duration = duration;
    musicPlayerStore.currentTime = currentTime;
  }

  async function handleLoaded() {
    musicPlayerStore.isPlaying = true;

    if (!musicQueueStore.musicPlayingNow) return;
    const { title, thumbnail, artists, album } = musicQueueStore.musicPlayingNow;

    navigator.mediaSession.metadata = new MediaMetadata({
      title,
      artwork: thumbnail ? [{ src: thumbnail }] : [],
      artist: punctuatify(artists.map(artist => artist.title) ?? []),
      album: album?.title,
    });
  }

  $effect(() => {
    const trackLoaded = !!musicQueueStore.musicPlayingNow;
    navigator.mediaSession.playbackState = trackLoaded
      ? musicPlayerStore.isPlaying
        ? "playing"
        : "paused"
      : "none";
  });

  $effect(() => {
    let player: StreamPlayer | null = null;

    function initializePlayer() {
      if (isTauri()) {
        if (!nativePlayer) return;
        player = new NativePlayer(nativePlayer, "audio");
      } else {
        if (!webEmbedPlayer) return;
        player = new WebEmbedPlayer(webEmbedPlayer, {
          playerVars: {
            autoplay: 0,
            controls: 0,
            disablekb: 1,
            playsinline: 1,
          },
        });
      }

      musicPlayerStore.musicPlayer = player;

      player.on("playing", handleOnPlay);
      player.on("paused", handleOnPause);
      player.on("ended", handleOnEnded);
      player.on("timeupdate", handleTimeUpdate);
      player.on("loaded", handleLoaded);
    }

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if (musicPlayerStore.isPlaying) {
        musicPlayerStore.pauseMusic();
      } else {
        musicPlayerStore.playMusic();
      }
    }

    initializePlayer();
    window.addEventListener("keypress", musicPlayerShortcuts);
    return () => {
      window.removeEventListener("keypress", musicPlayerShortcuts);
      player?.dispose();
    };
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicPlayerStore.musicPlayer || !musicQueueStore.musicPlayingNow) return;

      musicPlayerStore.progress = 0;
      await musicPlayerStore.musicPlayer.load(musicQueueStore.musicPlayingNow.videoId);
    }

    handleMusicPlayingNowChange();
  });
</script>

<div class="flex bg-black/35 backdrop-blur-xl backdrop-saturate-150 h-full w-full pl-4 pb-2">
  {#if isTauri()}
    <audio class="hidden" bind:this={nativePlayer}></audio>
  {:else}
    <div class="hidden" bind:this={webEmbedPlayer}></div>
  {/if}
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
