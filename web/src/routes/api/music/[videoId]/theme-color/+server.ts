import { error, json } from "@sveltejs/kit";
import getColors from "get-image-colors";

import { YT_IMG_API_URL } from "$lib/constants/urls.js";

export async function GET({ params: { videoId } }) {
  const response = await fetch(`${YT_IMG_API_URL}/vi/${videoId}/maxresdefault.jpg`);
  const arrayBuffer = await response.arrayBuffer();

  try {
    const resizedCover = await getColors(Buffer.from(arrayBuffer), { type: "image/jpeg" });
    const dominantColor = resizedCover[0].rgb();

    return json({
      success: true,
      data: dominantColor,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get dominant (theme) color of cover image.",
    });
  }
}
