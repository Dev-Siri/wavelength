import type { IYTScraperServer } from "./gen/yt_scraper_grpc_pb";

import getSearchSuggestions from "./rpcs/getSearchSuggestions";

export const ytScraperServer: IYTScraperServer = {
  getSearchSuggestions,
};
