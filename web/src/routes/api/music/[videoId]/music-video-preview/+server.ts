import { error, json } from "@sveltejs/kit";
import Fuse from "fuse.js";

import { youtubeV3Api } from "$lib/server/api/youtube.js";

// NOTE:
/*
  "The music video preview route" is at best, a guesser. It can only try to accurately
  match the song name / artist name to get the actual music video. But there are many times it
  may not be accurate. So a wrong music video or even a short can get selected. Since YouTube doesn't provide any
  filters (music vid/ track/ normal vid) whatsoever for these use cases.
 */

export async function GET({ url }) {
  const songTitle = url.searchParams.get("title");
  const artist = url.searchParams.get("artist");

  if (!songTitle)
    error(400, {
      success: false,
      message: "Song Title (title) search param is required.",
    });

  if (!artist)
    error(400, {
      success: false,
      message: "Artist (artist) search param is required.",
    });

  try {
    const response = await youtubeV3Api.search.list({
      q: `${artist} - ${songTitle} official music video`,
      part: ["id", "snippet"],
      videoCategoryId: "10",
      type: ["video"],
      order: "viewCount",
      maxResults: 10,
    });

    if (!response?.data?.items)
      error(404, {
        success: false,
        message: "Video not found.",
      });

    const fuse = new Fuse(response.data.items, {
      keys: ["snippet.title", "snippet.channelTitle"],
      ignoreLocation: true,
    });

    const keyword = `${artist.replace(",", "&").split("&")[0]} - ${songTitle
      .split(" ")
      .map(word => `'${word}`)
      .join("")} ('official 'lyric video) !animoji`;
    const filteredVids = fuse.search(keyword, { limit: 1 });
    const filteredVidId = filteredVids?.[0]?.item?.id?.videoId;

    if (!filteredVids.length)
      error(404, {
        success: false,
        message: "Video not found.",
      });

    return json({
      success: true,
      data: { videoId: filteredVidId ?? response.data.items[0].id?.videoId },
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get video preview.",
    });
  }
}
