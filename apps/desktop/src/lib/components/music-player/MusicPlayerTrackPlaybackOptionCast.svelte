<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";
  import { onMount } from "svelte";

  import { musicPlayer, musicPlayerStreamDevice } from "$lib/stream-player/audio/musicPlayer";

  import StreamResolver from "$lib/stream-player/audio/StreamResolver";
  import { punctuatify } from "$lib/utils/format";
  import { getUpscaledAlbumUrl } from "$lib/utils/url";
  import { buttonVariants } from "../ui/button";
  import * as Tooltip from "../ui/tooltip";

  async function castToDevice() {
    if (!musicPlayer.queue.playingNow) return;

    const context = cast.framework.CastContext.getInstance();
    const session = context.getCurrentSession();

    if (!session) return;

    const { videoId, videoType, title, artists, album, thumbnail, duration } =
      musicPlayer.queue.playingNow;

    const {
      url,
      source,
      metadata: { bitrate },
    } = await StreamResolver.fetch(videoId, videoType, {
      client: "TV_CAST",
    });

    const mediaInfo = new chrome.cast.media.MediaInfo(
      url,
      source.sourceType === "youtube" ? "audio/mp4" : "application/vnd.apple.mpegurl",
    );
    const mediaImage = new chrome.cast.Image(getUpscaledAlbumUrl(thumbnail));

    const metadata = new chrome.cast.media.MusicTrackMediaMetadata();
    metadata.metadataType = chrome.cast.media.MetadataType.MUSIC_TRACK;
    metadata.title = title;
    metadata.songName = title;
    metadata.artist = `${punctuatify(artists.map(artist => artist.title))}  ${
      bitrate >= 1_200_000
        ? source.sampleRate > 48000
          ? "•  Hi-Res Lossless"
          : "•  Lossless"
        : bitrate === 320_000
          ? "•  Hi-Fi Audio"
          : bitrate === 256_000
            ? "•  High Quality"
            : ""
    }`;
    metadata.images = [mediaImage];

    if (album?.title) metadata.albumName = album.title;

    mediaInfo.metadata = metadata;

    // @ts-expect-error untyped by lib.
    mediaInfo.hlsSegmentFormat = chrome.cast.media.HlsSegmentFormat.FMP4;
    // @ts-expect-error untyped by lib.
    mediaInfo.hlsVideoSegmentFormat = chrome.cast.media.HlsVideoSegmentFormat.FMP4;

    if (duration) {
      mediaInfo.duration = Number(duration);
      mediaInfo.metadata.duration = Number(duration);
    }

    const request = new chrome.cast.media.LoadRequest(mediaInfo);

    try {
      await session.loadMedia(request);
      musicPlayerStreamDevice.setCastingState(true);
    } catch (err) {
      console.error("Cast failed:", err);
    }
  }

  onMount(() => {
    function createCastContext() {
      if (!cast) return;

      const context = cast.framework.CastContext.getInstance();

      cast.framework.CastContext.getInstance().setOptions({
        receiverApplicationId: chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID,
        autoJoinPolicy: chrome.cast.AutoJoinPolicy.ORIGIN_SCOPED,
        resumeSavedSession: false,
      });

      context.addEventListener(cast.framework.CastContextEventType.SESSION_STATE_CHANGED, event => {
        if (event.sessionState === cast.framework.SessionState.SESSION_STARTED) {
          castToDevice();
        }

        if (event.sessionState === cast.framework.SessionState.SESSION_ENDED) {
          musicPlayerStreamDevice.stopCasting();
        }
      });
    }

    createCastContext();
  });
</script>

{#if !isTauri()}
  <Tooltip.Root>
    <Tooltip.Trigger
      class={buttonVariants({
        variant: "ghost",
        class: "w-fit px-3 rounded-full",
      })}
    >
      <google-cast-launcher></google-cast-launcher>
    </Tooltip.Trigger>
    <Tooltip.Content class="z-9999">
      <p>Cast</p>
    </Tooltip.Content>
  </Tooltip.Root>
{/if}

<style>
  google-cast-launcher {
    --disconnected-color: white;
    --connected-color: white;

    display: inline-flex !important;
    align-items: center;
    justify-content: center;
    width: 18px;
    height: 18px;
    filter: brightness(0) invert(1);
  }

  google-cast-launcher::part(button) {
    opacity: 1 !important;
    visibility: visible !important;
  }
</style>
