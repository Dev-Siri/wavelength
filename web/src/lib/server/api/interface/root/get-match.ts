import fetchFromRapidApi from "../rapid-api-fetcher";

type DisplayName =
  | "YouTube"
  | "YouTube Music"
  | "Apple Music"
  | "Spotify"
  | "Pandora"
  | "Deezer"
  | "SoundCloud"
  | "Amazon Music"
  | "TIDAL"
  | "Napster"
  | "Yandex"
  | "Spinrilla"
  | "Audius"
  | "Audiomack"
  | "Boomplay"
  | "Anghami";

type Platform =
  | "youtube"
  | "youtubeMusic"
  | "appleMusic"
  | "spotify"
  | "pandora"
  | "deezer"
  | "soundcloud"
  | "amazonMusic"
  | "tidal"
  | "napster"
  | "yandex"
  | "spinrilla"
  | "audius"
  | "audiomack"
  | "boomplay"
  | "anghami";

export interface Match {
  displayName: DisplayName;
  linkId: string;
  platform: Platform;
  show: boolean;
  uniqueId?: string;
  country?: string;
  url?: string;
  nativeAppUriMobile?: string;
  nativeAppUriDesktop?: string;
}

interface Options {
  id: string;
}

export default async function getMatch({ id }: Options) {
  const response = await fetchFromRapidApi<Match[]>("/matching", {
    searchParams: { id },
  });

  return response;
}
