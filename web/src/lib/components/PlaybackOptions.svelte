<script lang="ts">
  import { Columns3, MicVocal, PlaySquare } from "lucide-svelte";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  import { Button } from "./ui/button";
  import * as Tooltip from "./ui/tooltip";
  import VolumeSlider from "./VolumeSlider.svelte";

  function syncUVideoToMusic(fn: () => void) {
    if (musicQueueStore.musicPlayingNow?.videoType !== "uvideo") return fn();

    fn();

    setTimeout(async () => {
      const currentTime = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

      musicPlayerStore.musicPreviewPlayer?.seekTo(currentTime, true);
    }, 1500);
  }
</script>

<Tooltip.Root>
  <Tooltip.Trigger>
    <Button
      variant="ghost"
      class="w-fit px-3 rounded-full hidden sm:flex"
      onclick={() =>
        syncUVideoToMusic(
          () =>
            (musicPlayerStore.visiblePanel =
              musicPlayerStore.visiblePanel === "playingNow" ? null : "playingNow"),
        )}
    >
      <PlaySquare
        size={20}
        class={musicPlayerStore.visiblePanel === "playingNow"
          ? "text-primary"
          : "text-muted-foreground"}
      />
    </Button>
  </Tooltip.Trigger>
  <Tooltip.Content>
    <p>Now playing view</p>
  </Tooltip.Content>
</Tooltip.Root>
<Tooltip.Root>
  <Tooltip.Trigger>
    <Button
      variant="ghost"
      class="w-fit px-3 rounded-full"
      disabled={musicQueueStore.musicPlayingNow?.videoType === "uvideo"}
      onclick={() =>
        syncUVideoToMusic(
          () => (musicQueueStore.isMusicQueueVisible = !musicQueueStore.isMusicQueueVisible),
        )}
    >
      <Columns3
        size={20}
        class={musicQueueStore.isMusicQueueVisible ? "text-primary" : "text-muted-foreground"}
      />
    </Button>
  </Tooltip.Trigger>
  <Tooltip.Content>
    <p>Queue</p>
  </Tooltip.Content>
</Tooltip.Root>
<Tooltip.Root>
  <Tooltip.Trigger>
    <Button
      variant="ghost"
      class="w-fit px-3 rounded-full"
      disabled={musicQueueStore.musicPlayingNow?.videoType === "uvideo"}
      onclick={() =>
        syncUVideoToMusic(
          () =>
            (musicPlayerStore.visiblePanel =
              musicPlayerStore.visiblePanel === "lyrics" ? null : "lyrics"),
        )}
    >
      <MicVocal
        size={20}
        class={musicPlayerStore.visiblePanel === "lyrics"
          ? "text-primary"
          : "text-muted-foreground"}
      />
    </Button>
  </Tooltip.Trigger>
  <Tooltip.Content>
    <p>Lyrics</p>
  </Tooltip.Content>
</Tooltip.Root>
<VolumeSlider />
