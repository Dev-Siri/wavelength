import * as grpc from "@grpc/grpc-js";
import { z } from "zod";

import { SearchResponse, type SearchRequest } from "../gen/yt_scraper_pb";
import { music } from "../innertube";
import {
  searchSuggestionLinkSchema,
  searchSuggestionSchema,
} from "../schemas/search-suggestion";

export default async function getSearchSuggestions(
  call: grpc.ServerUnaryCall<SearchRequest, SearchResponse>,
  callback: grpc.sendUnaryData<SearchResponse>
) {
  const query = call.request.getQuery();
  const [suggestions, links] = await music.getSearchSuggestions(query);

  if (!suggestions) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube Music sent an empty response.")
      .build();
    return callback(status);
  }

  if (!suggestions.contents) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.NOT_FOUND)
      .withDetails("No matches for that query.")
      .build();
    return callback(status);
  }

  const parsedSuggestions = z
    .array(searchSuggestionSchema)
    .safeParse(suggestions.contents);

  if (!parsedSuggestions.success) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube Music sent an invalid response.")
      .build();
    return callback(status);
  }

  const response = new SearchResponse();
  const suggestedQueries: string[] = [];
  const suggestedLinks: SearchResponse.SuggestedLink[] = [];

  for (const query of parsedSuggestions.data) {
    suggestedQueries.push(query.suggestion.text);
  }

  response.setSuggestedQueriesList(suggestedQueries);
  response.setSuggestedLinksList(suggestedLinks);

  if (!links) return callback(null, response);

  const parsedLinks = z
    .array(searchSuggestionLinkSchema)
    .safeParse(links.contents);

  if (!parsedLinks.success) return callback(null, response);

  for (const link of parsedLinks.data) {
    const suggestedLink = new SearchResponse.SuggestedLink();
    const [titleCol, subtitleCol] = link.flex_columns;

    if (!titleCol || !subtitleCol) continue;

    suggestedLink.setType(link.item_type);
    suggestedLink.setTitle(titleCol.title.text);
    suggestedLink.setSubtitle(subtitleCol.title.text);
    suggestedLink.setBrowseId(link.id);
    suggestedLinks.push(suggestedLink);
  }

  response.setSuggestedQueriesList(suggestedQueries);
  callback(null, response);
}
