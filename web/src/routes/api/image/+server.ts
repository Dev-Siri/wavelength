import sharp from "sharp";

export async function GET({ url: { searchParams }, fetch }) {
  const imageUrl = searchParams.get("url");

  if (!imageUrl) return new Response("Image URL not provided");

  const imageResponse = await fetch(imageUrl);
  const imageBuffer = await imageResponse.arrayBuffer();

  try {
    const optimizedImage = await sharp(imageBuffer).resize().avif().toBuffer();
    const distributableImage = new Uint8Array(optimizedImage);

    return new Response(distributableImage, {
      headers: new Headers({ "Cache-Control": "public, max-age=86400" }),
    });
  } catch (err) {
    console.log(err);
    // Return the original image as-is instead of silently erroring in the server console
    // So the user gets an actual (Although unoptimized) image
    return new Response(imageBuffer);
  }
}
