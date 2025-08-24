import { error, json } from "@sveltejs/kit";

import { youtubeClient } from "$lib/server/api/youtube.js";

export async function GET({ params: { id } }) {
  try {
    const artistDetails = await youtubeClient.artists.getArtistDetails({ id });

    return json({
      success: true,
      data: artistDetails,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get artist details from YouTube.",
    });
  }
}
