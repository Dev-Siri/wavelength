<script lang="ts">
  import { Columns3Icon, MaximizeIcon, MicVocalIcon } from "@lucide/svelte";

  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";

  import { buttonVariants } from "../ui/button";
  import * as Tooltip from "../ui/tooltip";
  import MusicPlayerTrackPlaybackOptionInfo from "./MusicPlayerTrackPlaybackOptionInfo.svelte";
  import VolumeSlider from "./MusicPlayerVolumeSlider.svelte";

  const disabledStyles = "opacity-50 cursor-default hover:bg-transparent";

  const isLyricsAvailable = $derived(
    musicPlayer.queue.playingNow &&
      musicPlayer?.queue.playingNow?.videoType !== "VIDEO_TYPE_UVIDEO",
  );
</script>

<Tooltip.Root>
  <Tooltip.Trigger
    class={buttonVariants({ variant: "ghost", class: "w-fit px-3 rounded-full" })}
    onclick={() =>
      (musicInterfaceStore.isMusicQueueVisible = !musicInterfaceStore.isMusicQueueVisible)}
  >
    <Columns3Icon
      size={20}
      class="text-primary {musicInterfaceStore.isMusicQueueVisible ? '' : 'opacity-50'}"
    />
  </Tooltip.Trigger>
  <Tooltip.Content class="z-9999">
    <p>Queue</p>
  </Tooltip.Content>
</Tooltip.Root>
<Tooltip.Root>
  <Tooltip.Trigger
    class={buttonVariants({
      variant: "ghost",
      class: `w-fit px-3 rounded-full ${!isLyricsAvailable ? disabledStyles : ""}`,
    })}
    onclick={() =>
      isLyricsAvailable &&
      (musicInterfaceStore.visiblePanel =
        musicInterfaceStore.visiblePanel === "lyrics" ? null : "lyrics")}
  >
    <MicVocalIcon
      size={20}
      class="text-primary {musicInterfaceStore.visiblePanel === 'lyrics' ? '' : 'opacity-50'}"
    />
  </Tooltip.Trigger>
  <Tooltip.Content class="z-9999">
    <p>Lyrics</p>
  </Tooltip.Content>
</Tooltip.Root>
<VolumeSlider />
<MusicPlayerTrackPlaybackOptionInfo />
<Tooltip.Root>
  <Tooltip.Trigger
    class={buttonVariants({
      variant: "ghost",
      class: `w-fit px-3 rounded-full ${musicPlayer.queue.playingNow ? "" : disabledStyles}`,
    })}
    onclick={() => musicPlayer.queue.playingNow && musicInterfaceStore.goFullscreenMode()}
  >
    <MaximizeIcon
      size={20}
      class="text-primary {musicInterfaceStore.isPlayerFullscreen &&
      musicInterfaceStore.visiblePanel === 'lyrics'
        ? ''
        : 'opacity-50'}"
    />
  </Tooltip.Trigger>
  <Tooltip.Content class="z-9999">
    <p>Fullscreen Mode</p>
  </Tooltip.Content>
</Tooltip.Root>
