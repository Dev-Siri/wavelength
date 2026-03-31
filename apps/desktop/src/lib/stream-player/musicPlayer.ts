import { BASE_URL } from "$lib/constants/utils";
import { setupEventListeners } from "./eventListeners";
import { NATIVE_PLAYBACK_FORMAT } from "./NativePlayer";
import StreamPlayerFactory from "./StreamPlayerBuilder";
import StreamPlayerController from "./StreamPlayerController.svelte";

export const { musicPlayerStreamDevice, musicPlayerWebCompatibilityDevice } =
  StreamPlayerFactory.create({
    nativeOptions: {
      format: NATIVE_PLAYBACK_FORMAT.AUDIO,
    },
    webOptions: {
      host: BASE_URL,
      playerVars: {
        autoplay: 0,
        controls: 0,
        disablekb: 1,
        playsinline: 1,
      },
    },
  });

export const musicPlayer = new StreamPlayerController(musicPlayerStreamDevice);

export interface PlayerBindingTarget {
  native: HTMLAudioElement;
  webEmbed?: HTMLDivElement;
}

/**
 * Attaches the music player to the DOM and initializes window event listeners.
 *
 * @returns An `unlisten` function to clean up all event listeners.
 */
export function bindPlayerToApp({ native, webEmbed }: PlayerBindingTarget) {
  musicPlayerStreamDevice.attach(native);
  if (webEmbed) {
    musicPlayerWebCompatibilityDevice?.attach(webEmbed);
  }

  return setupEventListeners();
}
