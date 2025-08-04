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

export async function POST({ params: { email }, locals, url }) {
  const session = await locals.auth();

  const authorName = url.searchParams.get("authorName");
  const authorImage = url.searchParams.get("authorImage");

  if ((!session?.user?.name && !authorName) || (!session?.user?.image && !authorImage))
    error(401, {
      success: false,
      message: "Unauthorized",
    });

  try {
    const authName = session?.user?.name ?? authorName;
    const authImage = session?.user?.image ?? authorImage;

    if (!authName || !authImage) {
      return error(400, {
        success: false,
        message: "Author name or image is required.",
      });
    }

    await db.insert(playlists).values({
      name: "New Playlist",
      playlistId: crypto.randomUUID(),
      authorGoogleEmail: email,
      authorName: authName,
      authorImage: authImage,
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
