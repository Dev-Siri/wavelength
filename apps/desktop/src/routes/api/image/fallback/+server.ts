export async function GET({ url: { searchParams }, fetch }) {
  const imageUrl = searchParams.get("url");

  if (!imageUrl) return new Response("Image URL not provided.");

  const imageResponse = await fetch(imageUrl);
  const imageBuffer = await imageResponse.arrayBuffer();

  return new Response(imageBuffer, {
    headers: new Headers({ "Cache-Control": "public, max-age=86400" }),
  });
}
