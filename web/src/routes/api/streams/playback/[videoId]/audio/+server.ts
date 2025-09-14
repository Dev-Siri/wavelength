import { error, json } from "@sveltejs/kit";
import fs from "fs/promises";
import path from "path";
import { create as createYoutubeDl, type RequestedDownload } from "youtube-dl-exec";

export async function GET({ params: { videoId } }) {
  try {
    const binaryPath = path.join(process.cwd(), "vercel", "path0", "web");

    console.log(await fs.readdir(binaryPath));
    const youtubeDl = createYoutubeDl(path.join(binaryPath, "static", "bin", "yt-dlp"));
    const response = await youtubeDl(videoId, {
      dumpSingleJson: true,
      format: "bestaudio[ext=m4a]",
      audioQuality: 0,
    });

    const best: RequestedDownload = response.requested_downloads?.[0];

    if (!best || !("url" in best) || typeof best.url !== "string")
      throw new Error("No audio stream found.");

    return json({
      success: true,
      data: {
        url: best.url,
        ext: best.ext,
        abr: best.abr,
        duration: response.duration,
      },
    });
  } catch (err) {
    console.error(err);
    error(500, {
      success: false,
      message: "Failed to fetch playback stream URL.",
    });
  }
}
