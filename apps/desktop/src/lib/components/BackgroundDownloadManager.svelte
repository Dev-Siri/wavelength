<script lang="ts">
  import { useQueryClient } from "@tanstack/svelte-query";

  import type { Snippet } from "svelte";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import downloadStore from "$lib/stores/download.svelte";
  import { getDownloadsPath, updateDownloads } from "$lib/utils/download";
  import { backendClient } from "$lib/utils/query-client";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  const { children }: { children: Snippet } = $props();

  const queryClient = useQueryClient();

  $effect(() => {
    async function handleDownload() {
      if (!downloadStore.currentDownload?.videoId) return;

      const { invoke } = await import("@tauri-apps/api/core");
      const streamUrl = await invoke("fetch_highest_bitrate_audio_stream_url", {
        videoId: downloadStore.currentDownload.videoId,
      });
      const downloadsPath = await getDownloadsPath();

      await invoke("download_track", {
        streamUrl,
        output: `${downloadsPath}/${downloadStore.currentDownload.videoId}.m4a`,
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
