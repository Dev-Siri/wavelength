import type { ArtistSong } from "../types.js";

import fetchFromRapidApi from "../rapid-api-fetcher.js";

interface Options {
  id: string;
}

export interface ArtistResponse {
  title: string;
  description: string;
  thumbnail: string;
  subscriberCount: string;
  songs:
    | {
        browseId: string;
        titleHeader: string;
        contents: ArtistSong[];
      }
    | undefined;
}

export default async function getArtistDetails({ id }: Options) {
  const response = await fetchFromRapidApi<ArtistResponse>("/getArtists", {
    searchParams: { id },
  });

  return response;
}
