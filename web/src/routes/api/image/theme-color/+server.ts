import { error, json } from "@sveltejs/kit";
import getColors from "get-image-colors";

export interface ThemeColor {
  r: number;
  g: number;
  b: number;
}

export async function GET({ url: { searchParams } }) {
  const imageUrl = searchParams.get("url");

  if (!imageUrl) return new Response("Image URL not provided");

  const response = await fetch(imageUrl);
  const arrayBuffer = await response.arrayBuffer();

  try {
    const resizedCover = await getColors(Buffer.from(arrayBuffer), { type: "image/jpeg" });
    const [r, g, b] = resizedCover[0].rgb();

    return json({
      success: true,
      data: { r, g, b },
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get dominant (theme) color of image.",
    });
  }
}
