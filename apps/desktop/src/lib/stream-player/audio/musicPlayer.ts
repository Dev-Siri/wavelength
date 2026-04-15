import StreamPlayerController from "./StreamPlayerController.svelte";
import StreamPlayerFactory from "./StreamPlayerFactory";

export const musicPlayerStreamDevice = StreamPlayerFactory.create();

export const musicPlayer = new StreamPlayerController(musicPlayerStreamDevice);

export interface PlayerBindingTarget {
  native: HTMLAudioElement;
  webEmbed?: HTMLDivElement;
}

/**
 * Attaches the music player to the DOM.
 */
export function bindPlayerToApp(webTarget: HTMLAudioElement) {
  musicPlayerStreamDevice.attach(webTarget);
}
