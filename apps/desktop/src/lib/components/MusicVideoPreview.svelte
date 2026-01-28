<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { WebEmbedPlayer } from "$lib/stream-player/web-embed";

  const { musicVideoId }: { musicVideoId: string } = $props();

  let musicVideoPreview: HTMLDivElement;

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

  $effect(() => {
    const ytPlayer = new WebEmbedPlayer(musicVideoPreview, {
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

    musicPlayerStore.musicPreviewPlayer = ytPlayer;
    let interval: number;

    async function loadVideo() {
      const playerDuration = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

      await ytPlayer.load(
        musicVideoId,
        musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO" ? playerDuration : 10,
      );

      interval = setInterval(viewRandomChunks, 5000);
      await ytPlayer.mute();
    }

    loadVideo();

    return () => {
      clearInterval(interval);
      ytPlayer.dispose();
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
</script>

<div
  class="absolute h-[140%] -mt-24 w-full opacity-15 pointer-events-none left-0 right-0 duration-200"
  id="preview-player"
  bind:this={musicVideoPreview}
></div>

<style>
  #preview-player::after,
  #preview-player::before {
    -webkit-mask-image: linear-gradient(to bottom, transparent, black 80%);
    mask-image: linear-gradient(to bottom, transparent, black 80%);
  }
</style>
