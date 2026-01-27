import { redirect } from "@sveltejs/kit";
import z from "zod";

import { cookieKeys } from "$lib/constants/keys.js";
import { backendClient } from "$lib/utils/query-client.js";

export async function load({ locals, url, cookies }) {
  const session = await locals.auth();

  // Allow the user to access /app even when not logged in.
  // Just by default, redirect them to / from the start.
  // If the user is logged in, then don't even let them get back to /.
  // /downloads is accessible to everyone.
  if (session && !url.pathname.startsWith("/app") && url.pathname !== "/downloads")
    redirect(307, "/app");

  let authToken = cookies.get(cookieKeys.authToken);

  if (!authToken && session?.user) {
    const token = await backendClient("/auth/token", z.string(), {
      method: "POST",
      body: {
        id: session.user.id,
        email: session.user.email,
        displayName: session.user.name,
        photoUrl: session.user.image,
      },
    });

    cookies.set(cookieKeys.authToken, token, {
      path: "/",
      expires: new Date(9999, 0, 1),
      httpOnly: true,
      secure: false,
    });
    authToken = token;
  }

  return { session, authToken };
}
