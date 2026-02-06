<script lang="ts">
  import { EllipsisIcon, PlayIcon } from "@lucide/svelte";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { VideoType } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import userStore from "$lib/stores/user.svelte";
  import { durationify } from "$lib/utils/format";

  import ArtistLink from "../artist/ArtistLink.svelte";
  import ExplicitIndicator from "../ExplicitIndicator.svelte";
  import Image from "../Image.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import { Button } from "../ui/button";
  import * as DropdownMenu from "../ui/dropdown-menu";
  import TrackLikeButton from "./TrackLikeButton.svelte";

  const {
    music,
    toggle,
    playCount,
  }: {
    music: MusicTrack & { videoType?: VideoType };
    playCount?: string;
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
    class="flex rounded-2xl justify-between items-center duration-200 p-1.5 gap-2 hover:bg-muted w-full pr-4 group cursor-pointer"
  >
    <div
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex gap-2 text-start w-full"
    >
      <div
        class="flex flex-col aspect-square items-center justify-center relative group-hover:rounded-lg h-16 w-16 duration-200"
      >
        <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
        {#key music.thumbnail}
          <Image
            src={music.thumbnail}
            alt="Thumbnail"
            class="rounded-2xl aspect-square object-cover h-full w-full group-hover:opacity-40"
            height={64}
            width={70}
          />
        {/key}
      </div>
      <div class="flex flex-col gap-2 w-full mt-2">
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
      {#if music.duration}
        <p class="self-center text-sm text-muted-foreground pl-[9%]">
          {durationify(Number(music.duration))}
        </p>
      {:else}
        <div class="pr-[18%]"></div>
      {/if}
    </div>
    {#if userStore.user}
      <TrackLikeButton {music} />
    {/if}
    <DropdownMenu.Trigger class="h-full">
      <Button variant="ghost" class="flex items-center justify-center px-1 text-muted-foreground">
        <EllipsisIcon />
      </Button>
    </DropdownMenu.Trigger>
  </div>
  <DropdownMenu.Content>
    <PlaylistToggleOptions {music} {toggle} />
  </DropdownMenu.Content>
</DropdownMenu.Root>
