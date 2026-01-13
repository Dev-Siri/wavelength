import * as grpc from "@grpc/grpc-js";
import { z } from "zod";

import type { SuggestedLink } from "@/gen/proto/common.js";
import type {
  GetSearchSuggestionsRequest,
  GetSearchSuggestionsResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import {
  searchSuggestionLinkSchema,
  searchSuggestionSchema,
} from "@/schemas/search-suggestion.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getSearchSuggestions(
  call: grpc.ServerUnaryCall<
    GetSearchSuggestionsRequest,
    GetSearchSuggestionsResponse
  >,
  callback: grpc.sendUnaryData<GetSearchSuggestionsResponse>
) {
  try {
    const music = await getYtMusicClient();
    const [suggestions, links] = await music.getSearchSuggestions(
      call.request.query
    );

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

    const suggestedQueries: string[] = [];
    const suggestedLinks: SuggestedLink[] = [];

    for (const query of parsedSuggestions.data) {
      suggestedQueries.push(query.suggestion.text);
    }

    const response = {
      suggestedQueries,
      suggestedLinks,
    } satisfies GetSearchSuggestionsResponse;

    if (!links) return callback(null, response);

    const parsedLinks = z
      .array(searchSuggestionLinkSchema)
      .safeParse(links.contents);

    if (!parsedLinks.success) return callback(null, response);

    for (const link of parsedLinks.data) {
      const [titleCol, subtitleCol] = link.flex_columns;
      const thumbnail = getHighestQualityThumbnail(link.thumbnail);

      if (!titleCol || !subtitleCol || !thumbnail) continue;

      const suggestedLink = {
        type: link.item_type,
        title: titleCol.title.text,
        subtitle: subtitleCol.title.text,
        browseId: link.id,
        thumbnail: thumbnail.url,
      } satisfies SuggestedLink;

      suggestedLinks.push(suggestedLink);
    }

    response.suggestedQueries = suggestedQueries;
    return callback(null, response);
  } catch (error) {
    console.error("Search Suggestions fetch failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Search Suggestions fetch failed: " + String(error))
      .build();
    callback(status);
  }
}
