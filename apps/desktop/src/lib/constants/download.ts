import type { Platform } from "$lib/utils/platform";

export const DOWNLOAD_DIR = "downloads";
export const DOWNLOAD_STREAM_EXT = "m4a";

export const APP_REPO_LATEST_RELEASE_LINK =
  "https://github.com/Dev-Siri/wavelength/releases/latest/download";
export const APP_DOWNLOAD_LINKS: Partial<Record<Platform, string>> = {
  android: `${APP_REPO_LATEST_RELEASE_LINK}/app-release.apk`,
  darwin: `${APP_REPO_LATEST_RELEASE_LINK}/WavLen_darwin.dmg`,
} as const;
