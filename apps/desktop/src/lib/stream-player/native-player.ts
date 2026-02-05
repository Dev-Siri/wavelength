import { STREAM_PLAYBACK_URL } from "$lib/constants/utils";
import { getDownloadedStreamPath, isAlreadyDownloaded } from "$lib/utils/download";
import { StreamPlayer } from "./player";

export class NativePlayer extends StreamPlayer {
  public constructor(
    /** The element where the `NativePlayer` will attach to. */
    public playerElement: HTMLMediaElement,
    public resource: "audio" | "video",
  ) {
    super();
    this.forwardEvents();
  }

  private playingHandler = () => this.dispatchEvent(this.createEvent("playing"));
  private pausedHandler = () => this.dispatchEvent(this.createEvent("paused"));
  private endedHandler = () => this.dispatchEvent(this.createEvent("ended"));
  private timeUpdateHandler = async () => {
    const currentTime = await this.getCurrentTime();
    const duration = await this.getDuration();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime,
        duration,
      }),
    );
  };

  async dispose() {
    this.playerElement.removeEventListener("playing", this.playingHandler);
    this.playerElement.removeEventListener("paused", this.pausedHandler);
    this.playerElement.removeEventListener("ended", this.endedHandler);
    this.playerElement.removeEventListener("timeupdate", this.timeUpdateHandler);
  }

  async mute() {
    this.playerElement.muted = true;
  }

  async unMute() {
    this.playerElement.muted = false;
  }

  private forwardEvents() {
    this.playerElement.addEventListener("playing", this.playingHandler);
    this.playerElement.addEventListener("paused", this.pausedHandler);
    this.playerElement.addEventListener("ended", this.endedHandler);
    this.playerElement.addEventListener("timeupdate", this.timeUpdateHandler);
  }

  async load(videoId: string, startingSeconds?: number) {
    const { invoke } = await import("@tauri-apps/api/core");

    // Resetting the player: Causing a stop on another load actually provides a more "predictable" UX,
    // Than having the song continually play until the next track loads.
    await this.pause();
    this.playerElement.setAttribute("src", "");
    this.playerElement.setAttribute("autoplay", "true");

    if ((await isAlreadyDownloaded(videoId)) && this.resource !== "video") {
      const path = await getDownloadedStreamPath(videoId);

      this.playerElement.setAttribute(
        "src",
        `${STREAM_PLAYBACK_URL}/local-playback?url=${encodeURIComponent(path)}`,
      );
    } else {
      const streamUrl = await invoke<string | null | undefined>(
        `fetch_highest_bitrate_${this.resource}_stream_url`,
        { videoId },
      );

      if (!streamUrl) return;

      this.playerElement.setAttribute(
        "src",
        `${STREAM_PLAYBACK_URL}/stream-playback?url=${encodeURIComponent(streamUrl)}`,
      );
    }

    if (startingSeconds) this.playerElement.currentTime = startingSeconds;
    this.dispatchEvent(this.createEvent("loaded"));
  }

  async pause() {
    this.playerElement.pause();
    this.dispatchEvent(this.createEvent("paused"));
  }

  async play() {
    this.playerElement.play();
    this.dispatchEvent(this.createEvent("playing"));
  }

  async seek(to: number) {
    this.playerElement.currentTime = to;
    const duration = await this.getDuration();

    this.dispatchEvent(
      this.createEvent("timeupdate", {
        currentTime: to,
        duration,
      }),
    );
  }

  async getCurrentTime() {
    const time = this.playerElement.currentTime;
    return isNaN(time) ? 0 : time;
  }

  async getDuration() {
    const duration = this.playerElement.duration;
    return isNaN(duration) ? 0 : duration;
  }
}
