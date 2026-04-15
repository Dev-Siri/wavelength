<script lang="ts">
  import { Columns3Icon, MicVocalIcon, XIcon } from "@lucide/svelte";
  import { blur } from "svelte/transition";

  import type { Snippet } from "svelte";

  import useLiveAlbumCover from "$lib/queries/liveAlbumCover";
  import useMusicVideoPreviewQuery from "$lib/queries/musicVideoPreview";
  import connectivityStore from "$lib/stores/connectivity.svelte";
  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import settingsStore from "$lib/stores/settings.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { punctuatify } from "$lib/utils/format";

  import { getUpscaledAlbumUrl } from "$lib/utils/url";
  import AlbumLiveCover from "../album/AlbumLiveCover.svelte";
  import HifiBadge from "../HifiBadge.svelte";
  import Image from "../Image.svelte";
  import MusicPlayerControls from "../music-player/MusicPlayerControls.svelte";
  import MusicVideoPreview from "../MusicVideoPreview.svelte";
  import { Button } from "../ui/button";
  import TrackStatsOverlay from "./TrackStatsOverlay.svelte";

  const { children }: { children: Snippet } = $props();

  const musicVideoPreviewQuery = $derived(
    useMusicVideoPreviewQuery({
      title: musicPlayer.queue.playingNow?.title ?? "",
      artists: musicPlayer.queue.playingNow?.artists ?? [],
      videoType: musicPlayer.queue.playingNow?.videoType ?? "VIDEO_TYPE_TRACK",
    }),
  );

  const albumLiveCoverQuery = $derived(
    useLiveAlbumCover({
      albumId: musicPlayer.queue.playingNow?.album?.browseId ?? "",
      videoId: musicPlayer.queue.playingNow?.videoId ?? "",
    }),
  );

  const shouldShowPreviewVideo = $derived(
    musicVideoPreviewQuery.isSuccess &&
      connectivityStore.isOnline &&
      !settingsStore.settings.disableMusicVideoPreview,
  );
</script>

{#if musicPlayer.queue.playingNow}
  {@const { title, artists, album, thumbnail, videoType } = musicPlayer.queue.playingNow}
  <article class="flex relative h-full w-full">
    <Button
      variant="ghost"
      size="icon"
      class="absolute right-12 m-2 top-2 hover:scale-110 hover:bg-transparent"
      onclick={() => videoType === "VIDEO_TYPE_TRACK" && musicInterfaceStore.switchPanels()}
    >
      {#if musicInterfaceStore.isPlayerFullscreen}
        {#if musicInterfaceStore.visiblePanel === "lyrics" && videoType === "VIDEO_TYPE_TRACK"}
          <div class="scale-150 transition-all" in:blur>
            <MicVocalIcon />
          </div>
        {:else}
          <div class="scale-150 transition-all" in:blur>
            <Columns3Icon />
          </div>
        {/if}
      {/if}
    </Button>
    <Button
      variant="ghost"
      size="icon"
      class="absolute right-0 m-2 top-2 hover:scale-110 hover:bg-transparent"
      onclick={() => musicInterfaceStore.closeFullscreen()}
    >
      {#if musicInterfaceStore.isPlayerFullscreen}
        <div class="scale-200 transition-all">
          <XIcon />
        </div>
      {/if}
    </Button>
    <div in:blur class="flex flex-col items-center justify-center h-full w-1/2">
      <div
        class="relative w-[500px] select-none h-[500px] grid place-items-center aspect-square overflow-hidden rounded-sm"
      >
        {#if shouldShowPreviewVideo && musicVideoPreviewQuery.data?.videoId}
          <MusicVideoPreview musicVideoId={musicVideoPreviewQuery.data.videoId} />
        {:else if albumLiveCoverQuery.data?.liveAlbumCoverUri && connectivityStore.isOnline}
          <AlbumLiveCover liveCoverUri={albumLiveCoverQuery.data.liveAlbumCoverUri} />
        {/if}
        <Image
          src={getUpscaledAlbumUrl(thumbnail)}
          alt="{title}'s Cover"
          height={500}
          width={500}
          class="aspect-square object-cover -z-10 h-full w-full {shouldShowPreviewVideo
            ? 'absolute inset-0'
            : ''}"
        />
      </div>
      {#if musicInterfaceStore.isPlayerFullscreen}
        <div class="flex flex-col gap-2 w-[500px] pt-4 select-none">
          <MusicPlayerControls />
          <div class="flex flex-col gap-4">
            <div>
              <p class="font-semibold">{title}</p>
              <p class="text-gray-300 text-xs">
                <span>
                  {punctuatify(artists.map(artist => artist.title))}
                </span>
                {#if album}
                  <span>⸺ {album.title}</span>
                {/if}
              </p>
            </div>
            <div class="flex items-center justify-center">
              <HifiBadge />
            </div>
          </div>
        </div>
      {:else}
        <TrackStatsOverlay />
      {/if}
    </div>
    <div class="py-24 overflow-y-auto h-full w-1/2">
      {@render children?.()}
    </div>
  </article>
{/if}
