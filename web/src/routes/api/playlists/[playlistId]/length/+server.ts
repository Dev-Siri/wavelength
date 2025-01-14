import { error, json } from "@sveltejs/kit";
import { count, eq } from "drizzle-orm";

import db from "$lib/db/drizzle";
import { playlistTracks } from "$lib/db/schema";
import { parseDurationToSeconds } from "$lib/utils/format";

export async function GET({ params: { playlistId } }) {
  try {
    const [playlistTracksDurationData, playlistTrackCountData] = await Promise.all([
      db
        .select({
          duration: playlistTracks.duration,
        })
        .from(playlistTracks)
        .where(eq(playlistTracks.playlistId, playlistId)),
      db
        .select({ songCount: count() })
        .from(playlistTracks)
        .where(eq(playlistTracks.playlistId, playlistId)),
    ]);

    const durationNumbers = playlistTracksDurationData.map(({ duration }) =>
      parseDurationToSeconds(duration),
    );

    return json({
      success: true,
      data: {
        songCount: playlistTrackCountData[0].songCount,
        songDurationSecond: durationNumbers.reduce(
          (total, currentDuration) => total + currentDuration,
          0,
        ),
      },
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to fetch playlist play length with ID ${playlistId}`,
    });
  }
}
