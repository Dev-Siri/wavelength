import { error, json } from "@sveltejs/kit";

import { youtubeV3Api } from "$lib/server/api/youtube.js";

export async function GET({ url }) {
  const query = url.searchParams.get("q");

  if (!query)
    error(400, {
      success: false,
      message: "Query (q) is required for searching user videos.",
    });

  try {
    const {
      data: { items: data },
    } = await youtubeV3Api.search.list({
      part: ["snippet"],
      q: query,
      maxResults: 10,
    });

    if (!data)
      error(404, {
        success: false,
        message: `No results for query ${query}`,
      });

    return json({
      success: true,
      data,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get music videos from YouTube.",
    });
  }
}
