import type VideoStreamPlayer from "./VideoStreamPlayer";

import { fetchHighestQualityVideoStreamUrl } from "$lib/ipc/youtube";

// Sync music video every 15 seconds.
const SYNC_THRESHOLD = 15;
/** 6 hours */
const CACHE_EXPIRATION_MS = 6 * 60 * 60 * 1000;

interface CachedPreviewUrl {
  url: string;
  expiresAt: number;
}

export default class DesktopVideoStreamPlayer implements VideoStreamPlayer {
  private playerElement?: HTMLVideoElement | null;
  private lastSyncTime?: number | null = null;

  private cachedUrls = new Map<string, CachedPreviewUrl>();

  private playerWarn() {
    console.warn("Preview player not initialized. Did you forget to call .attach()?");
  }

  attach(playerElement?: HTMLVideoElement) {
    if (!playerElement) throw new Error("`playerElement` not found.");
    this.playerElement = playerElement;
  }

  async play() {
    if (!this.playerElement) return this.playerWarn();
    try {
      await this.playerElement.play();
    } catch {
      // ignore abort
    }
  }

  async pause() {
    if (!this.playerElement) return this.playerWarn();
    this.playerElement.pause();
  }

  async sync(audioTime: number) {
    if (!this.playerElement) return this.playerWarn();
    if (this.lastSyncTime == null) {
      this.lastSyncTime = audioTime;
      try {
        this.playerElement.currentTime = audioTime;
      } catch {
        /* */
      }
    }

    if (Math.abs(this.lastSyncTime - audioTime) > SYNC_THRESHOLD) {
      this.lastSyncTime = audioTime;

      try {
        if ("fastSeek" in this.playerElement) {
          this.playerElement.fastSeek(audioTime);
        } else {
          (this.playerElement as HTMLVideoElement).currentTime = audioTime;
        }
      } catch {
        this.playerElement.currentTime = audioTime;
      }
    }

    this.play();
  }

  async show(videoId: string) {
    if (!this.playerElement) return this.playerWarn();
    const previewStreamUrl = await this.fetchUrl(videoId);

    this.playerElement.loop = true;
    this.playerElement.muted = true;
    this.playerElement.src = previewStreamUrl;

    this.playerElement.preload = "auto";

    this.playerElement.load();

    await new Promise<void>(resolve => {
      if (this.playerElement!.readyState >= 1) return resolve();
      this.playerElement!.onloadedmetadata = () => resolve();
    });
  }

  dispose() {
    this.playerElement = null;
  }

  private async fetchUrl(videoId: string) {
    const cachedUrl = this.fetchFromCache(videoId);
    if (cachedUrl) return cachedUrl;

    const streamUrl = await fetchHighestQualityVideoStreamUrl(videoId);
    this.cachedUrls.set(videoId, {
      url: streamUrl,
      expiresAt: Date.now() + CACHE_EXPIRATION_MS,
    });
    return streamUrl;
  }

  private fetchFromCache(videoId: string) {
    const cachedUrl = this.cachedUrls.get(videoId);
    if (!cachedUrl) return;

    const now = Date.now();
    if (now > cachedUrl.expiresAt) {
      this.cachedUrls.delete(videoId);
      return;
    }

    return cachedUrl.url;
  }
}
