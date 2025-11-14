import { error } from "@sveltejs/kit";
import { Tydle } from "@wvlen/tydle";

export async function GET({ params: { videoId } }) {
  const tydle = new Tydle();

  try {
    const { streams } = await tydle.fetchStreams(videoId);
    // Filters out for an audio-only stream that does not require signature deciphering.
    const stream = streams
      .filter(stream => "url" in stream.source && stream.quality?.includes("audio_quality"))
      .sort((a, b) => b.tbr - a.tbr)[0];
    console.log(streams);

    if ("url" in stream.source) {
      return fetch(stream.source.url);
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
