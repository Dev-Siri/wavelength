<script lang="ts">
  import { MicVocal, PlaySquare } from "lucide-svelte";

  import { musicPlayer, musicPreviewPlayer, visiblePanel } from "$lib/stores/music-player";
  import { musicPlayingNow } from "$lib/stores/music-queue";

  import { Button } from "./ui/button";
  import * as Tooltip from "./ui/tooltip";
  import VolumeSlider from "./VolumeSlider.svelte";

  function syncUVideoToMusic(fn: () => void) {
    if ($musicPlayingNow?.videoType !== "uvideo") return fn();

    fn();

    setTimeout(async () => {
      const currentTime = (await $musicPlayer?.getCurrentTime()) ?? 0;

      $musicPreviewPlayer?.seekTo(currentTime, true);
    }, 1500);
  }
</script>

<Tooltip.Root>
  <Tooltip.Trigger>
    <Button
      variant="ghost"
      class="w-fit px-2.5 rounded-full"
      on:click={() =>
        syncUVideoToMusic(
          () => ($visiblePanel = $visiblePanel === "playingNow" ? null : "playingNow"),
        )}
    >
      <PlaySquare
        size={20}
        class={$visiblePanel === "playingNow" ? "text-primary" : "text-muted-foreground"}
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
      class="w-fit px-2.5 rounded-full"
      disabled={$musicPlayingNow?.videoType === "uvideo"}
      on:click={() =>
        syncUVideoToMusic(() => ($visiblePanel = $visiblePanel === "lyrics" ? null : "lyrics"))}
    >
      <MicVocal
        size={20}
        class={$visiblePanel === "lyrics" ? "text-primary" : "text-muted-foreground"}
      />
    </Button>
  </Tooltip.Trigger>
  <Tooltip.Content>
    <p>Lyrics</p>
  </Tooltip.Content>
</Tooltip.Root>
<VolumeSlider />
