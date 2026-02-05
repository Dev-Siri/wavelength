/// <reference types="user-agent-data-types" />
import { IOS_PLATFORMS, MACOS_PLATFORMS, WINDOWS_PLATFORMS } from "$lib/constants/platform";

export type Platform = ReturnType<typeof getPlatform>;

// https://stackoverflow.com/a/38241481
export function getPlatform() {
  const userAgent = window.navigator.userAgent;
  const platform = window.navigator?.userAgentData?.platform || window.navigator.platform;

  if (MACOS_PLATFORMS.indexOf(platform) !== -1) {
    return "darwin";
  } else if (IOS_PLATFORMS.indexOf(platform) !== -1) {
    return "ios";
  } else if (WINDOWS_PLATFORMS.indexOf(platform) !== -1) {
    return "windows";
  } else if (/Android/.test(userAgent)) {
    return "android";
  } else if (/Linux/.test(platform)) {
    return "linux";
  }
  return "unknown";
}
