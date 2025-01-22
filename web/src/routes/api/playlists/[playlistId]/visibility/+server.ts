import { error, json } from "@sveltejs/kit";
import { eq } from "drizzle-orm";

import db from "$lib/db/drizzle";
import { playlists } from "$lib/db/schema";

export async function PATCH({ params: { playlistId } }) {
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

    await db
      .update(playlists)
      .set({ isPublic: !playlist.isPublic })
      .where(eq(playlists.playlistId, playlistId));

    return json({
      success: true,
      messsage: `Visibility of playlist with ID ${playlistId} changed to ${playlist.isPublic ? "private" : "public"}`,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: `Failed to change visibility of playlist with ID ${playlistId}`,
    });
  }
}
