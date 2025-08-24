import fetchFromRapidApi from "../rapid-api-fetcher.js";

import type { Artist, MusicTrack } from "../types.js";

export const searchTypes = [
  "song",
  "videos",
  "albums",
  "artists",
  "featured_playlists",
  "community_playlists",
  "podcasts",
] as const;

export type SearchType = (typeof searchTypes)[number];

export interface MusicSearchResponse<T extends SearchType> {
  result: (T extends "artists" ? Artist : MusicTrack)[];
  nextPageToken: string;
}

interface Options {
  q: string;
  searchType?: SearchType;
  nextPageToken?: string;
}

export default async function searchMusic({ q, searchType = "song", nextPageToken }: Options) {
  const response = await fetchFromRapidApi<MusicSearchResponse<typeof searchType>>("/search", {
    searchParams: { q, type: searchType, nextPage: nextPageToken },
  });

  return response;
}
