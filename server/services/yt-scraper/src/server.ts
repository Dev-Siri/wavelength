import type { IYTScraperServer } from "./gen/proto/yt_scraper_grpc_pb";

import getAlbumDetails from "./rpcs/getAlbumDetails";
import getArtistDetails from "./rpcs/getArtistDetails";
import getQuickPicks from "./rpcs/getQuickPicks";
import getSearchSuggestions from "./rpcs/getSearchSuggestions";
import searchAlbums from "./rpcs/searchAlbums";
import searchArtists from "./rpcs/searchArtists";
import searchTracks from "./rpcs/searchTracks";

export const ytScraperServer: IYTScraperServer = {
  getSearchSuggestions,
  getQuickPicks,
  searchTracks,
  getAlbumDetails,
  searchArtists,
  searchAlbums,
  getArtistDetails,
};
