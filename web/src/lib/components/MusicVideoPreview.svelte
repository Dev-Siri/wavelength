<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { getStreamUrl } from "$lib/utils/url";

  const { musicVideoId }: { musicVideoId: string } = $props();

  let musicVideoPreview: HTMLVideoElement;

  $effect(() => {
    musicPlayerStore.musicPreviewPlayer = musicVideoPreview;

    musicVideoPreview.src = getStreamUrl(musicVideoId, "video");
  });

  $effect(() => {
    async function controlMusicVidToSong() {
      if (musicQueueStore.musicPlayingNow?.videoType !== "uvideo") return;

      musicVideoPreview.currentTime = musicPlayerStore.currentTime;

      if (musicPlayerStore.isPlaying) {
        musicVideoPreview.play();
      } else {
        musicVideoPreview.pause();
      }
    }

    controlMusicVidToSong();
  });
</script>

<video
  class="absolute h-[140%] -mt-24 w-full opacity-10 pointer-events-none left-0 right-0 duration-200"
  id="preview-player"
  height="100%"
  width="100%"
  muted
  loop
  bind:this={musicVideoPreview}
>
</video>

<style>
  #preview-player::after,
  #preview-player::before {
    -webkit-mask-image: linear-gradient(to bottom, transparent, black 80%);
    mask-image: linear-gradient(to bottom, transparent, black 80%);
  }
</style>
