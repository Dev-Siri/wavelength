<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";
  import { toast } from "svelte-sonner";

  import type { MusicTrack } from "$lib/schemas/music-track";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/MusicQueue.svelte";

  import userStore from "$lib/stores/user.svelte";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";
  import { reportErrorToBackend } from "$lib/utils/query-client";

  import ArtistLink from "../artist/ArtistLink.svelte";
  import ExplicitIndicator from "../ExplicitIndicator.svelte";
  import NowPlayingAnimation from "../NowPlayingAnimation.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import TrackDuration from "../track/TrackDuration.svelte";
  import TrackLikeButton from "../track/TrackLikeButton.svelte";
  import { buttonVariants } from "../ui/button";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const {
    music,
    context,
  }: {
    music: MusicTrack & { positionInAlbum: number };
    context: MusicPlaylistContextSource;
  } = $props();

  async function playSong() {
    try {
      await musicPlayer.load({ ...music, videoType: "VIDEO_TYPE_TRACK" }, context);
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "AlbumTrackTile: playSong()",
      });
    }
  }
</script>

<DropdownMenu.Root>
  <div
    class="flex rounded-2xl justify-between items-center duration-200 border-b border-border p-1.5 gap-2 hover:bg-muted/70 w-full pr-4 group cursor-pointer"
    tabindex={0}
    role="button"
    onclick={playSong}
    onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
  >
    <div class="flex h-full items-center">
      <div class="grid place-items-center aspect-square text-center h-full">
        {#if musicPlayer.queue.playingNow?.videoId === music.videoId}
          <div class="scale-90 pl-5 pr-3">
            <NowPlayingAnimation height={20} width={20} />
          </div>
        {:else}
          <p class="text-muted-foreground font-semibold h-5 px-6">{music.positionInAlbum}</p>
        {/if}
      </div>
      <div class="flex flex-col gap-2 w-fit justify-center mt-2 ml-2">
        <div class="flex items-center gap-2 w-full">
          <p class="leading-none text-base line-clamp-1 w-full font-semibold">{music.title}</p>
        </div>
        <div class="flex gap-2 items-center">
          {#if music.isExplicit}
            <ExplicitIndicator />
          {/if}
          {#each music.artists as artist, i (`album-track-${artist.browseId}`)}
            <ArtistLink {...artist} trailingComma={i + 1 !== music.artists.length} />
          {/each}
        </div>
      </div>
    </div>
    <div class="grid grid-cols-3 place-items-center w-1/3">
      {#if userStore.user}
        <TrackLikeButton {music} />
      {/if}
      {#if music.duration}
        <TrackDuration duration={music.duration} />
      {/if}
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
    </div>
  </div>
  <DropdownMenu.Content>
    <PlaylistToggleOptions
      {music}
      ui="dropdown"
      videoType="VIDEO_TYPE_TRACK"
      toggle={{ type: "add" }}
    />
  </DropdownMenu.Content>
</DropdownMenu.Root>
