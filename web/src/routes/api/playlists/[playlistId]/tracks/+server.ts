import { error, json } from "@sveltejs/kit";
import { and, count, eq } from "drizzle-orm";

import db from "$lib/db/drizzle";
import { playlistTracks } from "$lib/db/schema";
import { playlistTrackAdditionSchema } from "$lib/server/utils/validation/playlist-track-addition-schema.js";

export async function GET({ params: { playlistId } }) {
  try {
    const playlistTracksData = await db
      .select()
      .from(playlistTracks)
      .where(eq(playlistTracks.playlistId, playlistId));

    return json({
      success: true,
      data: playlistTracksData,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to fetch playlist tracks with ID ${playlistId}`,
    });
  }
}

// POST handler, but actually also can perform a sort of delete.
// if (song in playlist): then remove it from playlist
// else: add it to playlist
export async function POST({ params: { playlistId }, request }) {
  const body = await request.json();
  const validatedBody = playlistTrackAdditionSchema.safeParse(body);

  if (!validatedBody.success)
    return error(404, {
      success: false,
      message: "Failed to update playlist details.",
    });

  try {
    const songIdentificationCheck = and(
      eq(playlistTracks.playlistId, playlistId),
      eq(playlistTracks.videoId, validatedBody.data.videoId),
    );
    const songCountQuery = await db
      .select({
        songCount: count(),
      })
      .from(playlistTracks)
      .where(songIdentificationCheck);
    const { songCount } = songCountQuery[0];

    if (songCount > 0) await db.delete(playlistTracks).where(songIdentificationCheck);
    else
      await db.insert(playlistTracks).values({
        playlistId,
        playlistTrackId: crypto.randomUUID(),
        ...validatedBody.data,
      });

    return json({
      success: true,
      data: `${songCount > 0 ? "Removed" : "Added"} song ${songCount > 0 ? "from" : "to"} playlist successfully.`,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to fetch playlist tracks with ID ${playlistId}`,
    });
  }
}
