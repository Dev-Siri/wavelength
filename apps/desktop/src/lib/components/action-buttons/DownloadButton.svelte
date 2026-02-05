<script lang="ts">
  import { HardDriveDownloadIcon } from "@lucide/svelte";

  import type { MusicTrack } from "$lib/utils/validation/music-track";

  import downloadStore from "$lib/stores/download.svelte";
  import { isAlreadyDownloaded } from "$lib/utils/download";

  import toast from "svelte-french-toast";
  import Button from "../ui/button/button.svelte";

  const {
    tracks,
    source,
  }: {
    tracks: MusicTrack[];
    /** The source is what the toast will show after downloads are queued. Like "playlist" to show "Downloading playlist." */
    source: string;
  } = $props();

  const isWholeListAlreadyDownloaded = $derived.by(async () => {
    for (const track of tracks) {
      return await isAlreadyDownloaded(track.videoId);
    }
    return false;
  });

  async function download() {
    downloadStore.addToQueue(...tracks);
    const loadingToast = toast.loading(`Downloading ${source}`);
    setTimeout(() => toast.dismiss(loadingToast), 3000);
  }
</script>

{#await isWholeListAlreadyDownloaded then isWholeDownloaded}
  {#if !isWholeDownloaded}
    <Button variant="secondary" onclick={download}>
      <HardDriveDownloadIcon />
      Download
    </Button>
  {/if}
{/await}
