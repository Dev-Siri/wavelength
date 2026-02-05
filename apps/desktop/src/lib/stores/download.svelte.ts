import type { MusicTrack } from "$lib/utils/validation/music-track";

class DownloadStore {
  currentDownload = $state<MusicTrack | null>(null);
  activeDownloads = $state<MusicTrack[]>([]);

  addToQueue = (...downloadTrack: MusicTrack[]) => {
    const hasExisting = this.activeDownloads.some(active =>
      downloadTrack.some(track => track.videoId === active.videoId),
    );

    if (hasExisting) return;

    this.activeDownloads = [...this.activeDownloads, ...downloadTrack];

    this.nextDownload();
  };

  popQueue = (): MusicTrack | null => {
    const poppedTrack = this.activeDownloads[0];
    this.activeDownloads = this.activeDownloads.slice(1);
    return poppedTrack;
  };

  nextDownload = () => {
    if (this.currentDownload) return;

    const next = downloadStore.popQueue();
    if (!next) return;

    downloadStore.currentDownload = next;
  };
}

const downloadStore = new DownloadStore();

export default downloadStore;
