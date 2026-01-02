import type * as grpc from "@grpc/grpc-js";

import { SearchResponse, type SearchRequest } from "../gen/yt_scraper_pb";

export default function getSearchSuggestions(
  call: grpc.ServerUnaryCall<SearchRequest, SearchResponse>,
  callback: grpc.sendUnaryData<SearchResponse>
) {
  const query = call.request.getQuery();

  const res = new SearchResponse();
  callback(null, res);
}
