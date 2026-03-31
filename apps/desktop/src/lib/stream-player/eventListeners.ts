import { musicPlayer } from "./musicPlayer";

export function setupEventListeners() {
  window.addEventListener("keydown", handleMusicPlayerPlaystate);
  return () => window.removeEventListener("keydown", handleMusicPlayerPlaystate);
}

function handleMusicPlayerPlaystate(e: KeyboardEvent) {
  const keyIsSpace = e.key === "space";
  const isPageFocused = document.activeElement instanceof HTMLElement;
  const isFocusedElementInput = ["INPUT", "TEXTAREA"].includes(
    document.activeElement?.tagName ?? "",
  );
  const activeElement = document?.activeElement ?? {};
  const isFocusedElementEditable =
    "isContentEditable" in activeElement && activeElement.isContentEditable;
  const shouldTriggerPlaystateChange =
    keyIsSpace && isPageFocused && !isFocusedElementInput && isFocusedElementEditable;

  if (!shouldTriggerPlaystateChange) return;

  if (musicPlayer.isPlaying) {
    musicPlayer.pause();
  } else {
    musicPlayer.play();
  }
}
