export default interface VideoStreamPlayer {
  attach(playerElement?: HTMLVideoElement | HTMLDivElement): void;
  /**
   * Video stream players only have the `show` method. They are independent players from the Audio ones.
   * We do not care about whether they have all controls. They should at most be as interactable as an image.
   */
  show(videoId: string): Promise<void>;
  /**
   * Tell the video player to seek to the provided time to keep in sync with audio.
   */
  sync(audioTime: number): Promise<void>;
  play(): Promise<void>;
  pause(): Promise<void>;
  dispose(): void;
}
