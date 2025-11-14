import { error, json } from "@sveltejs/kit";
import { Tydle } from "@wvlen/tydle";

export async function GET({ getClientAddress, params: { videoId } }) {
  const tydle = new Tydle({
    sourceAddress: getClientAddress(),
  });

  try {
    const manifest = await tydle.fetchManifest(videoId);
    console.log({ manifest });
    const videoInfo = await tydle.fetchVideoInfoFromManifest(manifest);
    console.log({ videoInfo });
    const { streams } = await tydle.fetchStreamsFromManifest(manifest);
    console.log(streams);
    // Filters out for an audio-only stream that does not require signature deciphering.
    const stream = streams
      .filter(stream => "url" in stream.source && stream.quality?.includes("audio_quality"))
      .sort((a, b) => b.tbr - a.tbr)[0];

    if (!streams.length) {
      return error(404, { success: false, message: "No streams found." });
    }

    if ("url" in stream.source) {
      return json({ success: true, data: stream.source.url });
    }

    throw new Error(
      "URL was not found in source, playing this stream requires signature deciphering.",
    );
  } catch (err) {
    console.error(err);
    return error(500, {
      success: false,
      message: "Failed to get audio stream.",
    });
  }
}
