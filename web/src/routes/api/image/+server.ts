import sharp from "sharp";

export async function GET({ url: { searchParams }, fetch }) {
  const imageUrl = searchParams.get("url");
  const height = searchParams.get("h");

  if (!imageUrl) return new Response("Image URL not provided");

  const imageResponse = await fetch(imageUrl);
  const imageBuffer = await imageResponse.arrayBuffer();

  try {
    const optimizedImage = await sharp(imageBuffer).resize(Number(height)).avif().toBuffer();

    return new Response(optimizedImage, {
      headers: new Headers({ "Cache-Control": "public, max-age=86400" }),
    });
  } catch (error) {
    console.log(error);
    // Return the original image as-is instead of silently erroring in the server console
    // So the user gets an actual (Although unoptimized) image
    return new Response(imageBuffer);
  }
}
