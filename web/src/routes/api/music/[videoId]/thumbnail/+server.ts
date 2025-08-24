import { error } from "@sveltejs/kit";
import sharp from "sharp";

import { YT_IMG_API_URL } from "$lib/constants/urls.js";

export async function GET({ params: { videoId } }) {
  const response = await fetch(`${YT_IMG_API_URL}/vi/${videoId}/maxresdefault.jpg`);
  const buffer = await response.arrayBuffer();

  try {
    const resizedCover = await sharp(buffer).resize(256, 256, { fit: "cover" }).toBuffer();
    const distributableImage = new Uint8Array(resizedCover);

    return new Response(distributableImage);
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to fetch higher quality cover image.",
    });
  }
}
