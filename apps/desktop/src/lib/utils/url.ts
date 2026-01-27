import { PUBLIC_BACKEND_URL } from "$env/static/public";

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

export function getStreamUrl(videoId: string, streamType: "audio" | "video") {
  return new URL(`/stream/playback/${videoId}/${streamType}`, PUBLIC_BACKEND_URL).toString();
}
