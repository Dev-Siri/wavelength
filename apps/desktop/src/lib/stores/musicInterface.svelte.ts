import { localStorageKeys } from "$lib/constants/keys";

type MusicInfoPanels = "lyrics" | "queue";

class MusicInterfaceStore {
  visiblePanel = $state<MusicInfoPanels | null>(null);
  isMusicQueueVisible = $state(false);
  isPlayerFullscreen = $state(false);

  switchPanels() {
    if (musicInterfaceStore.visiblePanel === "lyrics") {
      musicInterfaceStore.visiblePanel = "queue";
    } else {
      musicInterfaceStore.visiblePanel = "lyrics";
    }

    localStorage.setItem(localStorageKeys.openPanel, musicInterfaceStore.visiblePanel);
  }

  goFullscreenMode() {
    const openPanel = localStorage.getItem(localStorageKeys.openPanel);

    if (openPanel !== "lyrics" && openPanel !== "queue") {
      musicInterfaceStore.visiblePanel = "lyrics";
    } else {
      musicInterfaceStore.visiblePanel = openPanel;
    }

    musicInterfaceStore.isPlayerFullscreen = true;
  }

  closeFullscreen() {
    musicInterfaceStore.isPlayerFullscreen = false;
    musicInterfaceStore.visiblePanel = null;
  }
}

const musicInterfaceStore = new MusicInterfaceStore();

export default musicInterfaceStore;
