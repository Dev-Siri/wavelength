<script lang="ts">
  import { useQueryClient } from "@tanstack/svelte-query";

  import type { Snippet } from "svelte";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import downloadStore from "$lib/stores/download.svelte";
  import { getDownloadsPath, updateDownloads } from "$lib/utils/download";
  import { punctuatify } from "$lib/utils/format";
  import { backendClient } from "$lib/utils/query-client";
  import { musicVideoPreviewSchema } from "$lib/utils/validation/music-video-preview";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  const { children }: { children: Snippet } = $props();

  const queryClient = useQueryClient();

  $effect(() => {
    async function handleDownload() {
      if (!downloadStore.currentDownload?.videoId) return;

      const musicVideoPreview = await backendClient(
        `/music/music-video-preview`,
        musicVideoPreviewSchema,
        {
          searchParams: {
            title: downloadStore.currentDownload.title,
            artist: punctuatify(downloadStore.currentDownload.artists.map(artist => artist.title)),
          },
        },
      );

      const { invoke } = await import("@tauri-apps/api/core");
      const streamUrl = await invoke("fetch_highest_bitrate_audio_stream_url", {
        videoId: downloadStore.currentDownload.videoId,
      });
      const musicVideoStreamUrl = await invoke("fetch_highest_bitrate_video_stream_url", {
        videoId: musicVideoPreview.videoId,
      });
      const downloadsPath = await getDownloadsPath();

      await invoke("download_track", {
        streamUrl,
        musicVideoStreamUrl,
        output: `${downloadsPath}/${downloadStore.currentDownload.videoId}`,
      });

      let duration = downloadStore.currentDownload.duration;
      if (!duration) {
        const fetchedDuration = await backendClient(
          `/music/track/${downloadStore.currentDownload.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
      }

      await updateDownloads({ ...downloadStore.currentDownload, duration });

      downloadStore.currentDownload = null;
      downloadStore.nextDownload();
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.downloads });
    }

    if (downloadStore.currentDownload) handleDownload();
  });
</script>

{@render children?.()}
