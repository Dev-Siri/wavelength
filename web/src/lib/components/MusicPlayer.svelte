<script lang="ts">
  import { get, set } from "idb-keyval";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { getStreamUrl, getThumbnailUrl } from "$lib/utils/url";

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
    async function loadTrack() {
      const current = musicQueueStore.musicPlayingNow;

      if (!current) return (navigator.mediaSession.metadata = null);

      if (musicPlayerElement.src) {
        URL.revokeObjectURL(musicPlayerElement.src);
        musicPlayerElement.src = "";
      }

      musicPlayerStore.isPlaying = false;
      musicPlayerStore.duration = 0;
      musicPlayerStore.currentTime = 0;

      const cachedBufferKey = `cached_audio_buffer-${current.videoId}`;
      const cachedBuffer = await get(cachedBufferKey);

      let decodedUrl: string;

      if (cachedBuffer instanceof ArrayBuffer) {
        const cachedBlob = new Blob([cachedBuffer]);
        decodedUrl = URL.createObjectURL(cachedBlob);
      } else {
        const res = await fetch(getStreamUrl(current.videoId, "audio"));

        if (!res.ok) return;

        const arrayBuffer = await res.arrayBuffer();

        await set(cachedBufferKey, arrayBuffer);

        const cachedBlob = new Blob([arrayBuffer]);
        decodedUrl = URL.createObjectURL(cachedBlob);
      }

      musicPlayerElement.src = decodedUrl;

      navigator.mediaSession.metadata = new MediaMetadata({
        title: current.title,
        artist: current.author,
        artwork: [
          {
            src: getThumbnailUrl(current.videoId),
            sizes: "256x256",
            type: "image/jpeg",
          },
        ],
      });
    }

    loadTrack();
  });
</script>

<div class="flex bg-black h-full w-full pl-3">
  <audio
    autoplay
    bind:this={musicPlayerElement}
    class="hidden"
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
