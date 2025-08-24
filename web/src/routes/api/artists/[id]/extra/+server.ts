import { error, json } from "@sveltejs/kit";

import { youtubeV3Api } from "$lib/server/api/youtube.js";

export async function GET({ params: { id } }) {
  try {
    const { data } = await youtubeV3Api.channels.list({
      part: ["snippet", "brandingSettings"],
      id: [id],
    });

    return json({
      success: true,
      data,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get artist details from YouTube.",
    });
  }
}
