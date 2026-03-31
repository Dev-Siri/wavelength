import type { MusicTrack } from "$lib/schemas/music-track";

interface DownloadTrack {
  downloadId: string;
  track: MusicTrack;
}

class DownloadStore {
  currentDownload = $state<DownloadTrack | null>(null);
  activeDownloads = $state<DownloadTrack[]>([]);

  addToQueue = (...downloadTrack: MusicTrack[]) => {
    const hasExisting = this.activeDownloads.some(active =>
      downloadTrack.some(track => track.videoId === active.track.videoId),
    );

    if (hasExisting) return;

    this.activeDownloads = [
      ...this.activeDownloads,
      ...downloadTrack.map(track => ({
        downloadId: crypto.randomUUID(),
        track,
      })),
    ];

    this.nextDownload();
  };

  popQueue = (): DownloadTrack | null => {
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
