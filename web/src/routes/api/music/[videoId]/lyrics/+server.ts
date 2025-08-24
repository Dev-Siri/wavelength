import { PRIVATE_LYRICS_RAPID_API_HOST, PRIVATE_RAPID_API_KEY } from "$env/static/private";
import { error, json } from "@sveltejs/kit";

import type { LyricsResponse } from "./types.js";

import { LYRICS_RAPID_API_URL } from "$lib/constants/urls.js";
import { youtubeClient } from "$lib/server/api/youtube.js";
import queryClient from "$lib/utils/query-client.js";

export async function GET({ params: { videoId } }) {
  try {
    const matchSongs = await youtubeClient.root.getMatch({ id: videoId });
    const spotifySong = matchSongs.find(song => song.platform === "spotify");

    if (!spotifySong || !spotifySong.uniqueId)
      error(404, {
        success: false,
        message: "No lyrics available.",
      });

    const spotifyTrackId = spotifySong.uniqueId.split("|").at(-1);

    if (!spotifyTrackId)
      error(404, {
        success: false,
        message: "No lyrics available.",
      });

    const lyricsResponse = await queryClient<LyricsResponse>(
      LYRICS_RAPID_API_URL,
      `/v1/track/lyrics`,
      {
        headers: {
          "X-RapidApi-Key": PRIVATE_RAPID_API_KEY,
          "X-RapidApi-Host": PRIVATE_LYRICS_RAPID_API_HOST,
        },
        searchParams: {
          trackId: spotifyTrackId,
          format: "json",
          removeNote: false,
        },
      },
    );

    return json({
      success: true,
      data: lyricsResponse,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "No lyrics available.",
    });
  }
}
