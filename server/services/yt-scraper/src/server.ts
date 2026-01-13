import type { YTScraperServer } from "@/gen/proto/yt_scraper.js";

import getAlbumDetails from "@/rpcs/getAlbumDetails.js";
import getArtistDetails from "@/rpcs/getArtistDetails.js";
import getQuickPicks from "@/rpcs/getQuickPicks.js";
import getSearchSuggestions from "@/rpcs/getSearchSuggestions.js";
import searchAlbums from "@/rpcs/searchAlbums.js";
import searchArtists from "@/rpcs/searchArtists.js";
import searchTracks from "@/rpcs/searchTracks.js";

export const ytScraperServer: YTScraperServer = {
  getSearchSuggestions,
  getQuickPicks,
  searchTracks,
  getAlbumDetails,
  searchArtists,
  searchAlbums,
  getArtistDetails,
};
