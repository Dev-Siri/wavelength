import { sequence } from "@sveltejs/kit/hooks";

import type { Handle } from "@sveltejs/kit";

import { handle as authHandle } from "./auth.js";

async function headersHandle({ event, resolve }: Parameters<Handle>[0]) {
  const responseAllHeaders = await resolve(event, {
    filterSerializedResponseHeaders: () => true,
  });

  return responseAllHeaders;
}

export const handle = sequence(authHandle, headersHandle);
