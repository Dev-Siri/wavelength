<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { VideoType } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import userStore from "$lib/stores/user.svelte";

  import AlbumLink from "../album/AlbumLink.svelte";
  import ArtistLink from "../artist/ArtistLink.svelte";
  import ExplicitIndicator from "../ExplicitIndicator.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import { Button } from "../ui/button";
  import * as DropdownMenu from "../ui/dropdown-menu";
  import TrackCover from "./TrackCover.svelte";
  import TrackDuration from "./TrackDuration.svelte";
  import TrackLikeButton from "./TrackLikeButton.svelte";

  const {
    music,
    toggle,
    playCount,
    showAlbum = true,
  }: {
    music: MusicTrack & { videoType?: VideoType };
    playCount?: string;
    showAlbum?: boolean;
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
      videoType: music.videoType ?? "VIDEO_TYPE_TRACK",
    } satisfies QueueableMusic;

    musicQueueStore.musicPlayingNow = queueableTrack;
    musicQueueStore.musicPlaylistContext = [];
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<DropdownMenu.Root>
  <div
    tabindex={0}
    role="button"
    onclick={playSong}
    onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
    class="flex rounded-2xl justify-between items-center duration-200 p-1.5 gap-2 hover:bg-muted/70 w-full pr-4 group cursor-pointer"
  >
    <div class="flex gap-2 {showAlbum && music.album ? 'w-1/3' : 'w-2/3'}">
      <TrackCover thumbnail={music.thumbnail} />
      <div class="flex flex-col gap-2 w-fit mt-2">
        <p class="leading-none text-md">
          {music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title}
        </p>
        <p class="text-sm text-muted-foreground leading-none -mt-1">
          {#if music.isExplicit}
            <ExplicitIndicator />
          {/if}
          {#each music.artists as artist, i}
            <ArtistLink
              {...artist}
              isUVideo={music.videoType === "VIDEO_TYPE_UVIDEO"}
              trailingComma={i < music.artists.length - 1}
            />
            {#if playCount}
              • {playCount}
            {/if}
          {/each}
        </p>
      </div>
    </div>
    {#if showAlbum && music.album}
      <div class="grid place-items-center w-1/3">
        <AlbumLink {...music.album} />
      </div>
    {/if}
    <div class="flex items-center justify-end gap-2 w-1/3">
      {#if userStore.user}
        <TrackLikeButton {music} />
      {/if}
      {#if music.duration}
        <TrackDuration duration={music.duration} />
      {/if}
      <DropdownMenu.Trigger class="h-full">
        <Button variant="ghost" size="icon" class="text-muted-foreground">
          <EllipsisIcon />
        </Button>
      </DropdownMenu.Trigger>
    </div>
  </div>
  <DropdownMenu.Content>
    <PlaylistToggleOptions {music} {toggle} />
  </DropdownMenu.Content>
</DropdownMenu.Root>
