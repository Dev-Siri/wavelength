import { error, json } from "@sveltejs/kit";
import { and, count, eq, gt, gte, lt, lte, sql } from "drizzle-orm";

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
export async function PUT({ params: { playlistId }, url }) {
  const prevIndex = Number(url.searchParams.get("prevIndex"));
  const nextIndex = Number(url.searchParams.get("nextIndex"));
  const playlistTrackId = url.searchParams.get("playlistTrackId");

  if (Number.isNaN(prevIndex) || Number.isNaN(nextIndex) || !playlistTrackId) {
    return error(400, {
      success: false,
      message: "Invalid `prevIndex`, `nextIndex`, or `playlistTrackId` provided.",
    });
  }

  console.log({ prevIndex, nextIndex, playlistTrackId });

  try {
    if (nextIndex < prevIndex) {
      // Shift down for tracks in the range [nextIndex, prevIndex - 1]
      const shiftedDown = await db
        .update(playlistTracks)
        .set({
          positionInPlaylist: sql`${playlistTracks.positionInPlaylist} + 1`,
        })
        .where(
          and(
            eq(playlistTracks.playlistId, playlistId),
            gte(playlistTracks.positionInPlaylist, nextIndex),
            lt(playlistTracks.positionInPlaylist, prevIndex),
          ),
        )
        .execute();

      console.log("Shifted Down Rows:", shiftedDown);
    } else if (nextIndex > prevIndex) {
      // Shift up for tracks in the range [prevIndex + 1, nextIndex]
      const shiftedUp = await db
        .update(playlistTracks)
        .set({
          positionInPlaylist: sql`${playlistTracks.positionInPlaylist} - 1`,
        })
        .where(
          and(
            eq(playlistTracks.playlistId, playlistId),
            gt(playlistTracks.positionInPlaylist, prevIndex),
            lte(playlistTracks.positionInPlaylist, nextIndex),
          ),
        )
        .execute();

      console.log("Shifted Up Rows:", shiftedUp);
    }

    // Update the specific track to its new position
    const updatedTrack = await db
      .update(playlistTracks)
      .set({
        positionInPlaylist: nextIndex,
      })
      .where(
        and(
          eq(playlistTracks.playlistId, playlistId),
          eq(playlistTracks.playlistTrackId, playlistTrackId),
        ),
      )
      .execute();

    console.log("Updated Track Position:", updatedTrack);

    return json({
      success: true,
      message: "Playlist positions updated successfully.",
    });
  } catch (err) {
    console.error("Error updating playlist positions:", err);
    return error(500, {
      success: false,
      message: "Failed to update playlist positions.",
    });
  }
}
