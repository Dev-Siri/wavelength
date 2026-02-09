<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";

  import ExplicitIndicator from "../ExplicitIndicator.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import TrackDuration from "../track/TrackDuration.svelte";
  import { Button } from "../ui/button";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const {
    music,
    toggle,
  }: {
    music: MusicTrack;
    toggle:
      | { type: "add" }
      | {
          type: "remove";
          from: Playlist;
        };
  } = $props();

  function playSong() {
    const queueableTrack = {
      ...music,
      videoType: "VIDEO_TYPE_TRACK",
    } satisfies QueueableMusic;

    musicQueueStore.musicPlaylistContext = [];
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<DropdownMenu.Root>
  <div
    class="flex rounded-lg items-center duration-200 p-1.5 gap-2 hover:bg-muted w-full px-4 group cursor-pointer"
  >
    <div
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex items-center gap-2 text-start w-full"
    >
      <div class="flex items-center gap-2 w-full">
        {#if music.isExplicit}
          <ExplicitIndicator />
        {/if}
        <p class="leading-none text-sm">
          {music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title}
        </p>
      </div>
      <TrackDuration duration={music.duration} />
    </div>
    {#if music.duration !== ""}
      <DropdownMenu.Trigger class="h-full">
        <Button variant="ghost" class="flex items-center justify-center px-1 text-muted-foreground">
          <EllipsisIcon />
        </Button>
      </DropdownMenu.Trigger>
    {/if}
  </div>
  <DropdownMenu.Content>
    <PlaylistToggleOptions {music} {toggle} />
  </DropdownMenu.Content>
</DropdownMenu.Root>
