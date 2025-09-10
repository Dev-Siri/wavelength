import { error, json } from "@sveltejs/kit";
import { and, count, eq } from "drizzle-orm";

import type { FullQueryResults } from "@neondatabase/serverless";

import db from "$lib/db/drizzle.js";
import { playlistTracks } from "$lib/db/schema.js";
import { playlistTrackAdditionSchema } from "$lib/server/utils/validation/playlist-track-addition-schema.js";
import { trackPositionUpdateSchema } from "$lib/server/utils/validation/track-position-update.js";

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
      .select({ songCount: count() })
      .from(playlistTracks)
      .where(songIdentificationCheck);
    const { songCount } = songCountQuery[0];

    if (songCount > 0) {
      await db.delete(playlistTracks).where(songIdentificationCheck);
      return json({
        success: true,
        data: "Removed song from playlist successfully.",
      });
    }

    const totalSongCountInPlaylist = await db
      .select({
        totalSongCount: count(),
      })
      .from(playlistTracks)
      .where(eq(playlistTracks.playlistId, playlistId));

    await db.insert(playlistTracks).values({
      playlistId,
      playlistTrackId: crypto.randomUUID(),
      ...validatedBody.data,
      positionInPlaylist: totalSongCountInPlaylist[0].totalSongCount + 1,
    });

    return json({
      success: true,
      data: "Added song to playlist successfully.",
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to fetch playlist tracks with ID ${playlistId}`,
    });
  }
}

// Rearrange playlist tracks
export async function PUT({ params: { playlistId }, request }) {
  const body = await request.json();
  const validatedBody = trackPositionUpdateSchema.safeParse(body);

  if (!validatedBody.success)
    return error(400, {
      success: false,
      message: "Invalid position data provided.",
    });

  try {
    const dbOperations: Promise<Omit<FullQueryResults<false>, "rows"> & { rows: never[] }>[] = [];

    for (const position of validatedBody.data) {
      const operation = db
        .update(playlistTracks)
        .set({
          positionInPlaylist: position.newPos,
        })
        .where(
          and(
            eq(playlistTracks.playlistId, playlistId),
            eq(playlistTracks.playlistTrackId, position.playlistTrackId),
          ),
        )
        .execute();

      dbOperations.push(operation);
    }

    await Promise.all(dbOperations);

    return json({
      success: true,
      data: "Playlist positions updated successfully.",
    });
  } catch (err) {
    console.error("Error updating playlist positions:", err);
    return error(500, {
      success: false,
      message: "Failed to update playlist positions.",
    });
  }
}
