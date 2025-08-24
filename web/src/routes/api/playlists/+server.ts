import { error, json } from "@sveltejs/kit";
import { and, eq, ilike } from "drizzle-orm";

import db from "$lib/db/drizzle.js";
import { playlists } from "$lib/db/schema.js";

export async function GET({ url }) {
  const query = url.searchParams.get("q");

  try {
    const playlistsResponse = await db
      .select()
      .from(playlists)
      .limit(10)
      .where(and(ilike(playlists.name, `%${query ?? ""}%`), eq(playlists.isPublic, true)));

    return json({
      success: true,
      data: playlistsResponse,
    });
  } catch (err) {
    console.log(err);
    return error(500, {
      success: false,
      message: "Failed to get public playlists.",
    });
  }
}
