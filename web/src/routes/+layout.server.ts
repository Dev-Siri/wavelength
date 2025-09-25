import { redirect } from "@sveltejs/kit";

import type { ApiResponse } from "$lib/types.js";

import { backendClient } from "$lib/utils/query-client.js";

export async function load({ locals, url }) {
  const session = await locals.auth();

  // Allow the user to access /app even when not logged in.
  // Just by default, redirect them to / from the start.
  // If the user is logged in, then don't even let them get back to /.
  // /downloads is accessible to everyone.
  if (session && !url.pathname.startsWith("/app") && url.pathname !== "/downloads")
    redirect(307, "/app");

  const region = await backendClient<ApiResponse<string>>("/region");

  return { session, region };
}
