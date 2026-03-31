<script lang="ts">
  import { HardDriveDownloadIcon } from "@lucide/svelte";

  import type { MusicTrack } from "$lib/schemas/music-track";

  import { isDownloaded } from "$lib/ipc/download";
  import downloadStore from "$lib/stores/download.svelte";

  import { toast } from "svelte-sonner";
  import Button from "../ui/button/button.svelte";

  const {
    tracks,
    source,
  }: {
    tracks: MusicTrack[] | (() => MusicTrack[]);
    /** The source is what the toast will show after downloads are queued. Like "playlist" to show "Downloading playlist." */
    source: string;
  } = $props();

  const isWholeListAlreadyDownloaded = $derived.by(async () => {
    const fetchedTracks = typeof tracks === "function" ? tracks() : tracks;
    for (const track of fetchedTracks) {
      const isStreamDownloaded = await isDownloaded(track.videoId);
      if (!isStreamDownloaded) return false;
    }

    return true;
  });

  async function download() {
    const fetchedTracks = typeof tracks === "function" ? tracks() : tracks;
    downloadStore.addToQueue(...fetchedTracks);
    const loadingToast = toast.loading(`Downloading ${source}`);
    setTimeout(() => toast.dismiss(loadingToast), 3000);
  }
</script>

{#await isWholeListAlreadyDownloaded then isWholeDownloaded}
  {#if !isWholeDownloaded}
    <Button title="Download" variant="ghost" size="sm" onclick={download}>
      <HardDriveDownloadIcon />
    </Button>
  {/if}
{/await}
