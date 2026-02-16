<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { NativePlayer } from "$lib/stream-player/native-player";
  import type { StreamPlayer } from "$lib/stream-player/player";
  import { WebEmbedPlayer } from "$lib/stream-player/web-embed";

  const { musicVideoId }: { musicVideoId: string } = $props();

  let musicVideoPreviewWebEmbed: HTMLDivElement | null = $state(null);
  let musicVideoPreviewNative: HTMLVideoElement | null = $state(null);

  let interval: number | null = null;

  async function viewRandomChunks() {
    if (
      musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO" ||
      !musicPlayerStore.musicPreviewPlayer
    )
      return;

    const currentTime = await musicPlayerStore.musicPreviewPlayer.getCurrentTime();
    const duration = await musicPlayerStore.musicPreviewPlayer.getDuration();

    if (currentTime >= duration - 20) await musicPlayerStore.musicPreviewPlayer.load(musicVideoId);

    await musicPlayerStore.musicPreviewPlayer.seek(currentTime + 10);
    await musicPlayerStore.musicPreviewPlayer.play();
  }

  async function loadVideo() {
    const playerDuration = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

    await musicPlayerStore.musicPreviewPlayer?.load(
      musicVideoId,
      musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO" ? playerDuration : 10,
    );

    interval = setInterval(viewRandomChunks, 5000);
    await musicPlayerStore.musicPreviewPlayer?.mute();
  }

  $effect(() => {
    let ytPlayer: StreamPlayer | null = null;

    function initializePlayer() {
      if (isTauri()) {
        if (!musicVideoPreviewNative) return;
        ytPlayer = new NativePlayer(musicVideoPreviewNative, "video");
      } else {
        if (!musicVideoPreviewWebEmbed) return;
        ytPlayer = new WebEmbedPlayer(musicVideoPreviewWebEmbed, {
          playerVars: {
            controls: 0,
            loop: 1,
            playsinline: 0,
            modestbranding: 1,
            rel: 0,
            iv_load_policy: 3,
            disablekb: 1,
            fs: 0,
          },
        });
      }

      musicPlayerStore.musicPreviewPlayer = ytPlayer;
    }

    initializePlayer();
    loadVideo();
    return () => {
      if (interval) clearInterval(interval);
      ytPlayer?.dispose();
      musicPlayerStore.musicPreviewPlayer = null;
    };
  });

  $effect(() => {
    async function controlMusicVidToSong() {
      if (
        musicQueueStore.musicPlayingNow?.videoType !== "VIDEO_TYPE_UVIDEO" ||
        !musicPlayerStore.musicPreviewPlayer
      )
        return;

      const playerDuration = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

      if (musicPlayerStore.isPlaying) {
        musicPlayerStore.musicPreviewPlayer.seek(playerDuration);
        musicPlayerStore.musicPreviewPlayer.play();
      } else {
        musicPlayerStore.musicPreviewPlayer.seek(playerDuration);
        musicPlayerStore.musicPreviewPlayer.pause();
      }
    }

    controlMusicVidToSong();
  });

  const playerClasses =
    "absolute h-[140%] -mt-24 w-full opacity-15 pointer-events-none left-0 right-0 duration-200";
</script>

{#if isTauri()}
  <video id="preview-player" muted loop class={playerClasses} bind:this={musicVideoPreviewNative}>
    <track kind="captions" />
  </video>
{:else}
  <div id="preview-player" class={playerClasses} bind:this={musicVideoPreviewWebEmbed}></div>
{/if}

<style>
  #preview-player::after,
  #preview-player::before {
    -webkit-mask-image: linear-gradient(to bottom, transparent, black 80%);
    mask-image: linear-gradient(to bottom, transparent, black 80%);
  }
</style>
