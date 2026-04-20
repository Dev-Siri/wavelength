import { dev } from "$app/environment";
import {
  PUBLIC_BACKEND_URL,
  PUBLIC_DEV_BACKEND_URL,
  PUBLIC_DEV_PLAYER_URL,
  PUBLIC_PLAYER_URL,
} from "$env/static/public";

import type { QueueableMusic } from "$lib/stream-player/queue/MusicQueue";
import type { z } from "zod";

import { WAVELENGTH_PLATFORM_KEY } from "$lib/constants/keys";
import { PROD_URL } from "$lib/constants/utils";
import userStore from "$lib/stores/user.svelte";
import { apiResponseSchema, type ApiResponse } from "../schemas/api-response";

type Method =
  | "GET"
  | "POST"
  | "PUT"
  | "DELETE"
  | "OPTIONS"
  | "HEAD"
  | "TRACE"
  | "CONNECT"
  | "PATCH";

interface Options {
  method: Method;
  body: Record<string, unknown> | object;
  searchParams: Record<string, unknown>;
  headers: Record<string, unknown>;
}

async function queryClient<T extends z.ZodTypeAny>(
  baseUrl: string,
  endpoint: string,
  dataSchema: T,
  { method = "GET", body, searchParams, headers }: Partial<Options> = {},
): Promise<z.infer<T>> {
  const url = new URL(endpoint, baseUrl);

  const authHeaders: Record<string, string> = userStore.authToken
    ? {
        Authorization: `Bearer ${userStore.authToken}`,
      }
    : {};
  const requestHeaders: Record<string, string> = {
    "Content-Type": "application/json",
    ...authHeaders,
    ...headers,
  };

  if (searchParams)
    Object.keys(searchParams).forEach(
      searchParamKey =>
        searchParams[searchParamKey] &&
        url.searchParams.set(searchParamKey, String(searchParams[searchParamKey])),
    );

  const opts = {
    method,
    body: JSON.stringify(body),
    headers: requestHeaders,
  };

  try {
    const response = await fetch(url, opts);

    if (!response.headers.get("Content-Type")?.includes("application/json"))
      throw new Error("Response does not follow the app's spec to use JSON.");

    const jsonResponse = await response.json();
    const validatedResponse = apiResponseSchema(dataSchema).parse(jsonResponse) as ApiResponse<T>;

    if (!validatedResponse.success) throw new Error(validatedResponse.message);

    return validatedResponse.data;
  } catch (error: unknown) {
    await reportErrorToBackend({
      error,
      source: "queryClient",
    });
    throw error;
  }
}

export async function reportErrorToBackend({ error, source }: { error: unknown; source: string }) {
  await fetch(`${dev ? PUBLIC_DEV_BACKEND_URL : PUBLIC_BACKEND_URL}/diagnostics/report-error`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      error: JSON.stringify(error),
      source,
      platform: WAVELENGTH_PLATFORM_KEY,
    }),
  });
}

export function reportStream({
  track,
  type,
}: {
  track: QueueableMusic;
  type: "skipFast" | "play30s" | "playStart";
}) {
  const authHeaders: Record<string, string> = userStore.authToken
    ? {
        Authorization: `Bearer ${userStore.authToken}`,
      }
    : {};

  try {
    void fetch(`${dev ? PUBLIC_DEV_PLAYER_URL : PUBLIC_PLAYER_URL}/player/record`, {
      method: "POST",
      keepalive: true,
      headers: {
        ...authHeaders,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        type,
        timestamp: Date.now(),
        track,
      }),
    });
  } catch {
    // We do not care if this fails, as it's just for analytics and does not affect user experience in any way.
  }
}

function createQueryClient(
  baseUrl: string,
  { defaultHeaders }: { defaultHeaders?: Record<string, unknown> } = {},
) {
  return async <T extends z.ZodTypeAny>(
    endpoint: string,
    dataSchema: T,
    options: Partial<Options> = {},
  ) =>
    queryClient<T>(baseUrl, endpoint, dataSchema, {
      ...options,
      headers: {
        ...defaultHeaders,
        ...options.headers,
      },
    });
}

export const backendClient = createQueryClient(dev ? PUBLIC_DEV_BACKEND_URL : PUBLIC_BACKEND_URL);
export const streamClient = createQueryClient(dev ? PUBLIC_DEV_PLAYER_URL : PUBLIC_PLAYER_URL, {
  defaultHeaders: {
    "X-Wavelength-Client": "WEB",
    "X-Sec-Fetch-Site": "cross-site",
    "X-Referer": PROD_URL,
  },
});
