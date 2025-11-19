import { YOUTUBE_BASE64_COOKIES } from "$env/static/private";
import { error, json } from "@sveltejs/kit";
import { parseNetscapeCookies, Tydle } from "@wvlen/tydle";

export async function GET({ getClientAddress, params: { videoId } }) {
  const tydle = new Tydle({
    authCookies: parseNetscapeCookies(atob(YOUTUBE_BASE64_COOKIES)),
    sourceAddress: getClientAddress(),
    defaultClient: "android",
  });

  try {
    const manifest = await tydle.fetchManifest(videoId);
    console.log("manifest:", JSON.stringify(manifest, null, 2));
    const videoInfo = await tydle.fetchVideoInfoFromManifest(manifest);
    console.log("videoinfo:", JSON.stringify(videoInfo, null, 2));
    const { streams } = await tydle.fetchStreamsFromManifest(manifest);
    console.log(streams);
    // Filters out for an audio-only stream that does not require signature deciphering.
    const stream = streams
      .filter(stream => "url" in stream.source && stream.codec.acodec && !stream.codec.vcodec)
      .sort((a, b) => b.tbr - a.tbr)[0];

    if (!streams.length) {
      return error(404, { success: false, message: "No streams found." });
    }

    if ("url" in stream.source) {
      return json({ success: true, data: stream.source.url });
    }

    return error(500, {
      success: false,
      message: "URL was not found in source, playing this stream requires signature deciphering.",
    });
  } catch (err) {
    console.error(err);
    throw err;
  }
}
