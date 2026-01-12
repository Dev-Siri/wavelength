import * as grpc from "@grpc/grpc-js";
import { z } from "zod";

import { SuggestedLink } from "../gen/proto/common_pb";
import {
  GetSearchSuggestionsResponse,
  type GetSearchSuggestionsRequest,
} from "../gen/proto/yt_scraper_pb";
import { music } from "../innertube";
import {
  searchSuggestionLinkSchema,
  searchSuggestionSchema,
} from "../schemas/search-suggestion";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function getSearchSuggestions(
  call: grpc.ServerUnaryCall<
    GetSearchSuggestionsRequest,
    GetSearchSuggestionsResponse
  >,
  callback: grpc.sendUnaryData<GetSearchSuggestionsResponse>
) {
  try {
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

    const response = new GetSearchSuggestionsResponse();
    const suggestedQueries: string[] = [];
    const suggestedLinks: SuggestedLink[] = [];

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
      const suggestedLink = new SuggestedLink();
      const [titleCol, subtitleCol] = link.flex_columns;

      if (!titleCol || !subtitleCol) continue;

      suggestedLink.setType(link.item_type);
      suggestedLink.setTitle(titleCol.title.text);
      suggestedLink.setSubtitle(subtitleCol.title.text);
      suggestedLink.setBrowseId(link.id);

      const thumbnail = getHighestQualityThumbnail(link.thumbnail);

      if (thumbnail) suggestedLink.setThumbnail(thumbnail.url);
      suggestedLinks.push(suggestedLink);
    }

    response.setSuggestedQueriesList(suggestedQueries);
    callback(null, response);
  } catch (error) {
    console.error("Search Suggestions fetch failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Search Suggestions fetch failed.")
      .build();
    callback(status);
  }
}
