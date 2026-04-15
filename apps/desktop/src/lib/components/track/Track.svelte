<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";
  import { toast } from "svelte-sonner";

  import type { MusicTrack } from "$lib/schemas/music-track";
  import type { Playlist, PlaylistVideoType } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/queue/MusicQueue";

  import userStore from "$lib/stores/user.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { reportErrorToBackend } from "$lib/utils/query-client";

  import AlbumLink from "../album/AlbumLink.svelte";
  import ArtistLink from "../artist/ArtistLink.svelte";
  import ExplicitIndicator from "../ExplicitIndicator.svelte";
  import PlaylistToggleOptions, {
    type PlaylistToggle,
  } from "../playlist/PlaylistToggleOptions.svelte";
  import { buttonVariants } from "../ui/button";
  import * as ContextMenu from "../ui/context-menu";
  import * as DropdownMenu from "../ui/dropdown-menu";
  import TrackCover from "./TrackCover.svelte";
  import TrackDirectAdd from "./TrackDirectAdd.svelte";
  import TrackDuration from "./TrackDuration.svelte";
  import TrackLikeButton from "./TrackLikeButton.svelte";

  const {
    music,
    toggle,
    playCount,
    context,
    showAlbum = true,
    isPreLiked,
  }: {
    music: MusicTrack & { videoType?: PlaylistVideoType };
    context?: MusicPlaylistContextSource;
    playCount?: string;
    showAlbum?: boolean;
    isPreLiked?: boolean;
    toggle:
      | PlaylistToggle
      | {
          type: "add-direct";
          to: Playlist;
        };
  } = $props();

  async function playSong() {
    try {
      await musicPlayer.load(
        {
          ...music,
          videoType: music.videoType ?? "VIDEO_TYPE_TRACK",
        },
        context ?? { type: "none" },
      );
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "Track: playSong()",
      });
    }
  }

  const displayArtists = $derived(
    music.artists.length > 3 ? music.artists.slice(0, 2) : music.artists,
  );
  const isArtistsShortened = $derived(displayArtists.length !== music.artists.length);
  const normalAdd = $derived<PlaylistToggle>(
    toggle.type === "add-direct" ? { type: "add" } : toggle,
  );
</script>

<ContextMenu.Root>
  <ContextMenu.Content>
    <PlaylistToggleOptions
      ui="contextmenu"
      videoType={music.videoType}
      {music}
      toggle={normalAdd}
    />
  </ContextMenu.Content>
  <ContextMenu.Trigger>
    <DropdownMenu.Root>
      <DropdownMenu.Content>
        <PlaylistToggleOptions
          ui="dropdown"
          videoType={music.videoType}
          {music}
          toggle={normalAdd}
        />
      </DropdownMenu.Content>
      <div
        tabindex={0}
        role="button"
        onclick={playSong}
        onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
        class="flex rounded-md justify-between items-center duration-200 p-1.5 gap-2 hover:bg-muted/70 w-full pr-4 group cursor-pointer"
      >
        <div class="flex items-center gap-2 {showAlbum && music.album ? 'w-1/3' : 'w-2/3'}">
          <TrackCover {...music} />
          <div class="flex flex-col gap-2 w-fit justify-center">
            <p class="leading-none text-base line-clamp-1 w-full font-semibold">{music.title}</p>
            <p class="text-sm text-muted-foreground leading-none">
              {#if music.isExplicit}
                <ExplicitIndicator />
              {/if}
              {#each displayArtists as artist, i (`track-${artist.browseId}-${i}`)}
                <ArtistLink
                  {...artist}
                  isUVideo={music.videoType === "VIDEO_TYPE_UVIDEO"}
                  trailingComma={i < displayArtists.length - 1}
                />
              {/each}
              {#if isArtistsShortened}
                <span class="-ml-2">...</span>
              {/if}
              {#if playCount}
                <span class="text-xs">
                  • {playCount}
                </span>
              {/if}
            </p>
          </div>
        </div>
        {#if showAlbum && music.album}
          <div class="grid place-items-center w-1/3">
            <AlbumLink {...music.album} />
          </div>
        {/if}
        <div class="grid grid-cols-3 place-items-center w-1/3">
          {#if userStore.user}
            <TrackLikeButton {isPreLiked} {music} />
          {/if}
          {#if music.duration}
            <TrackDuration duration={music.duration} />
          {/if}
          {#if toggle.type === "add-direct"}
            <TrackDirectAdd {music} playlistId={toggle.to.playlistId} />
          {:else}
            <DropdownMenu.Trigger
              class={buttonVariants({
                variant: "ghost",
                size: "icon",
                class: "text-muted-foreground",
              })}
              onclick={e => e.stopPropagation()}
            >
              <EllipsisIcon />
            </DropdownMenu.Trigger>
          {/if}
        </div>
      </div>
    </DropdownMenu.Root>
  </ContextMenu.Trigger>
</ContextMenu.Root>
