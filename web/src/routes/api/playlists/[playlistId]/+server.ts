import { error, json } from "@sveltejs/kit";
import { eq } from "drizzle-orm";

import db from "$lib/db/drizzle.js";
import { playlists } from "$lib/db/schema.js";
import { playlistDetailsEditSchema } from "$lib/server/utils/validation/playlist-details-edit-schema.js";

export async function GET({ params: { playlistId } }) {
  try {
    const playlistResponse = await db
      .select()
      .from(playlists)
      .where(eq(playlists.playlistId, playlistId));
    const playlist = playlistResponse?.[0];

    if (!playlist)
      error(404, {
        success: false,
        message: "Playlist not found.",
      });

    return json({
      success: true,
      data: playlist,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to fetch playlist with ID ${playlistId}`,
    });
  }
}

export async function DELETE({ params: { playlistId } }) {
  try {
    await db.delete(playlists).where(eq(playlists.playlistId, playlistId));

    return json({
      success: true,
      data: `Deleted playlist with ID ${playlistId}`,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to delete playlist with ID ${playlistId}`,
    });
  }
}

export async function PUT({ params: { playlistId }, request }) {
  const body = await request.json();
  const validatedBody = playlistDetailsEditSchema.safeParse(body);

  if (!validatedBody.success)
    return error(404, {
      success: false,
      message: "Failed to update playlist details.",
    });

  try {
    await db.update(playlists).set(validatedBody.data).where(eq(playlists.playlistId, playlistId));

    return json({
      success: true,
      data: `Updated playlist with ID ${playlistId}`,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to update playlist with ID ${playlistId}`,
    });
  }
}
