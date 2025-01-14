import { error, json } from "@sveltejs/kit";
import { eq } from "drizzle-orm";

import db from "$lib/db/drizzle";
import { playlists } from "$lib/db/schema";

export async function GET({ params: { email } }) {
  try {
    const playlistsData = await db
      .select()
      .from(playlists)
      .where(eq(playlists.authorGoogleEmail, email));

    return json({
      success: true,
      data: playlistsData,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to get playlists",
    });
  }
}

export async function POST({ params: { email }, locals }) {
  const session = await locals.auth();

  if (!session || !session?.user?.name || !session?.user?.image)
    error(401, {
      success: false,
      message: "Unauthorized",
    });

  try {
    await db.insert(playlists).values({
      name: "New Playlist",
      playlistId: crypto.randomUUID(),
      authorGoogleEmail: email,
      authorName: session.user.name,
      authorImage: session.user.image,
      coverImage: null,
    });

    return json({
      success: true,
      data: `Created new playlist for ${email}`,
    });
  } catch (err) {
    console.log(err);
    error(500, {
      success: false,
      message: "Failed to create new playlist for user.",
    });
  }
}
