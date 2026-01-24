<script lang="ts">
  import { PlayIcon, ShuffleIcon } from "@lucide/svelte";

  import type { QueueableMusic } from "$lib/stores/music-queue.svelte";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { shuffle } from "$lib/utils/shuffle";

  import { Button } from "../ui/button";

  const { tracks }: { tracks: QueueableMusic[] } = $props();

  function playAll() {
    musicQueueStore.musicPlaylistContext = tracks;
    musicQueueStore.musicPlayingNow = tracks[0];
    musicPlayerStore.playMusic();
  }

  function shuffleAndPlayAll() {
    musicPlayerStore.isShuffleModeOn = !musicPlayerStore.isShuffleModeOn;
    if (musicPlayerStore.isShuffleModeOn) {
      musicQueueStore.musicPlaylistContextPreshuffle = musicQueueStore.musicPlaylistContext;
      musicQueueStore.musicPlaylistContext = shuffle(musicQueueStore.musicPlaylistContext);
    } else {
      musicQueueStore.musicPlaylistContext = musicQueueStore.musicPlaylistContextPreshuffle;
      musicQueueStore.musicPlaylistContextPreshuffle = [];
    }
  }
</script>

<div class="flex gap-2">
  <Button onclick={playAll}>
    <PlayIcon fill="1" />
    Play All
  </Button>
  <Button variant="secondary" onclick={shuffleAndPlayAll}>
    <ShuffleIcon fill="1" />
    Shuffle
  </Button>
</div>
