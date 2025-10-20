<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import MusicPlayerTrackLabel from "./MusicPlayerTrackLabel.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";

  $effect(() => {
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

    return () => window.removeEventListener("keypress", musicPlayerShortcuts);
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicQueueStore.musicPlayingNow) return;

      await musicPlayerStore.loadTrack(musicQueueStore.musicPlayingNow.videoId);
      musicPlayerStore.playMusic();
    }

    handleMusicPlayingNowChange();
  });
</script>

<div class="flex bg-black h-full w-full pl-3">
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
