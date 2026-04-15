<script lang="ts">
  import { PlayIcon, ShuffleIcon } from "@lucide/svelte";
  import { toast } from "svelte-sonner";

  import type {
    MusicPlaylistContextSource,
    QueueableMusic,
  } from "$lib/stream-player/queue/MusicQueue";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { reportErrorToBackend } from "$lib/utils/query-client";
  import { shuffleStartIndex } from "$lib/utils/shuffle";

  import { Button } from "../ui/button";

  const {
    tracks,
    context,
  }: { tracks: QueueableMusic[] | (() => QueueableMusic[]); context?: MusicPlaylistContextSource } =
    $props();

  async function playAll() {
    try {
      const starterTrack = (typeof tracks === "function" ? tracks() : tracks)[
        musicPlayer.queue.shuffleEnabled ? shuffleStartIndex(tracks.length) : 0
      ];
      await musicPlayer.load(starterTrack, context);
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "PlaylistPlayOptions: playAll()",
      });
    }
  }

  async function shuffleAndPlayAll() {
    musicPlayer.queue.enableShuffle();
    await playAll();
  }
</script>

<div class="flex gap-2">
  <Button onclick={playAll} size="sm" class="px-6">
    <PlayIcon fill="1" />
    Play
  </Button>
  <Button variant="secondary" class="px-4.5" size="sm" onclick={shuffleAndPlayAll}>
    <ShuffleIcon fill="1" />
    Shuffle
  </Button>
</div>
