import { error, json } from "@sveltejs/kit";

import type { CountryCode } from "$lib/constants/countries.js";

import { youtubeClient } from "$lib/server/api/youtube.js";

export async function GET({ url }) {
  const regionCode = url.searchParams.get("regionCode") as CountryCode | undefined;

  try {
    const quickPickSongs = await youtubeClient.home.getQuickPicks({ gl: regionCode });

    return json({
      success: true,
      data: quickPickSongs.results,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get music videos from YouTube.",
    });
  }
}
