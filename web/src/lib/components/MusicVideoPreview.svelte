<script lang="ts">
  import createYouTubePlayer from "youtube-player";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  const { musicVideoId }: { musicVideoId: string } = $props();

  let musicVideoPreview: HTMLDivElement;

  async function viewRandomChunks() {
    if (
      musicQueueStore.musicPlayingNow?.videoType === "uvideo" ||
      !musicPlayerStore.musicPreviewPlayer
    )
      return;

    const currentTime = await musicPlayerStore.musicPreviewPlayer.getCurrentTime();
    const duration = await musicPlayerStore.musicPreviewPlayer.getDuration();

    if (currentTime >= duration - 20)
      await musicPlayerStore.musicPreviewPlayer.loadVideoById(musicVideoId, 10);

    await musicPlayerStore.musicPreviewPlayer.seekTo(currentTime + 10, true);
    await musicPlayerStore.musicPreviewPlayer.playVideo();
  }

  $effect(() => {
    const ytPlayer = createYouTubePlayer(musicVideoPreview, {
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
    let interval: NodeJS.Timeout;

    async function loadVideo() {
      const playerDuration = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

      await ytPlayer.loadVideoById(
        musicVideoId,
        musicQueueStore.musicPlayingNow?.videoType === "uvideo" ? playerDuration : 10,
      );

      interval = setInterval(viewRandomChunks, 5000);

      await ytPlayer.mute();
    }

    loadVideo();

    return () => {
      clearInterval(interval);
      ytPlayer.destroy();
    };
  });

  $effect(() => {
    async function controlMusicVidToSong() {
      if (
        musicQueueStore.musicPlayingNow?.videoType !== "uvideo" ||
        !musicPlayerStore.musicPreviewPlayer
      )
        return;

      const playerDuration = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

      if (musicPlayerStore.isMusicPlaying) {
        musicPlayerStore.musicPreviewPlayer.seekTo(playerDuration, true);
        musicPlayerStore.musicPreviewPlayer.playVideo();
      } else {
        musicPlayerStore.musicPreviewPlayer.seekTo(playerDuration, true);
        musicPlayerStore.musicPreviewPlayer.pauseVideo();
      }
    }

    controlMusicVidToSong();
  });
</script>

<div
  class="absolute h-[140%] -mt-24 w-full opacity-10 pointer-events-none left-0 right-0 duration-200"
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
