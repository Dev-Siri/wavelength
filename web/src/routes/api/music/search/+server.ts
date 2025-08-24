import { error, json } from "@sveltejs/kit";

import { searchTypes } from "$lib/server/api/interface/search/search-music.js";
import { youtubeClient } from "$lib/server/api/youtube.js";
import { isValidMusicSearchType } from "$lib/utils/validation/search.js";

export async function GET({ url }) {
  const query = url.searchParams.get("q");
  const searchType = url.searchParams.get("searchType") ?? "song";
  const nextPageToken = url.searchParams.get("nextPageToken") ?? undefined;

  if (!query)
    error(400, {
      success: false,
      message: "Query (q) is required for searching music.",
    });

  if (!isValidMusicSearchType(searchType))
    error(400, {
      success: false,
      message: `Search type (type) is not one of ${searchTypes.join(", ")}`,
    });

  try {
    const searchResult = await youtubeClient.search.searchMusic({
      q: query,
      searchType,
      nextPageToken,
    });

    return json({
      success: true,
      data: searchResult,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get music videos from YouTube.",
    });
  }
}
