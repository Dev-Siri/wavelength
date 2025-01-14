import { error, json } from "@sveltejs/kit";

import { youtubeV3Api } from "$lib/server/api/youtube";

export async function GET({ params: { videoId } }) {
  try {
    const response = await youtubeV3Api.videos.list({
      part: ["statistics"],
      id: [videoId],
    });

    const stats = response.data.items?.[0].statistics;

    if (!stats)
      error(404, {
        success: false,
        message: "Video stats not found.",
      });

    return json({
      success: true,
      data: stats,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get video stats.",
    });
  }
}
