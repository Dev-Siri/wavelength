import type { IYTScraperServer } from "./gen/proto/yt_scraper_grpc_pb";

import getQuickPicks from "./rpcs/getQuickPicks";
import getSearchSuggestions from "./rpcs/getSearchSuggestions";

export const ytScraperServer: IYTScraperServer = {
  getSearchSuggestions,
  getQuickPicks,
};
