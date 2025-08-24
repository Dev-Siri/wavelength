import type { SearchType } from "$lib/server/api/interface/search/search-music.js";

export function isValidMusicSearchType(searchType: string): searchType is SearchType {
  return searchType.includes(searchType);
}
