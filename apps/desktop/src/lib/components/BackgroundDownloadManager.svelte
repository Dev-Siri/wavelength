<script lang="ts">
  import { useQueryClient } from "@tanstack/svelte-query";
  import { isTauri } from "@tauri-apps/api/core";

  import type { Snippet } from "svelte";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { downloadTrack } from "$lib/ipc/download";
  import { musicTrackDurationSchema } from "$lib/schemas/track-length";
  import downloadStore from "$lib/stores/download.svelte";
  import { backendClient } from "$lib/utils/query-client";

  const { children }: { children: Snippet } = $props();

  const queryClient = useQueryClient();

  $effect(() => {
    async function handleDownload() {
      if (!downloadStore.currentDownload) return;
      const { track, downloadId } = downloadStore.currentDownload;
      let { duration } = track;

      await downloadTrack({ track, downloadId });

      if (!duration) {
        const fetchedDuration = await backendClient(
          `/music/track/${track.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
      }

      downloadStore.currentDownload = null;
      downloadStore.nextDownload();
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.downloads });
    }

    if (downloadStore.currentDownload && isTauri()) handleDownload();
  });
</script>

{@render children?.()}
