import { PUBLIC_BACKEND_URL } from "$env/static/public";
import { isTauri } from "@tauri-apps/api/core";

type UrlValidity =
  | {
      isValid: false;
    }
  | {
      isValid: true;
      url: URL;
    };

export function checkUrlValidity(uncheckedString: string): UrlValidity {
  try {
    const urlRegex = /(https?:\/\/[^\s)\]}>"]+)/;
    const match = uncheckedString.match(urlRegex);

    if (match) {
      const cleanedUrl = match[0];
      const url = new URL(cleanedUrl);

      return { isValid: true, url };
    }

    return { isValid: false };
  } catch {
    return { isValid: false };
  }
}

export function getThumbnailUrl(videoId: string) {
  return new URL(`/music/track/${videoId}/thumbnail`, PUBLIC_BACKEND_URL).toString();
}

export async function openUrl(url: string) {
  if (isTauri()) {
    const { openUrl: openUrlNative } = await import("@tauri-apps/plugin-opener");
    return await openUrlNative(url);
  }

  window.open(url);
}
