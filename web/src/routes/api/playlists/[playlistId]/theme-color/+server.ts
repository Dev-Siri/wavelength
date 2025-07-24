import { error, json } from "@sveltejs/kit";
import getColors from "get-image-colors";

export async function GET({ url }) {
  const playlistImageUrl = url.searchParams.get("playlistImageUrl");

  if (!playlistImageUrl)
    return error(400, {
      success: false,
      message: "Playlist image URL is required.",
    });

  const response = await fetch(playlistImageUrl);
  const arrayBuffer = await response.arrayBuffer();

  try {
    const resizedCover = await getColors(Buffer.from(arrayBuffer), { type: "image/jpeg" });
    const dominantColor = resizedCover[0].hex();

    return json({
      success: true,
      data: dominantColor,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get dominant (theme) color of cover image",
    });
  }
}
