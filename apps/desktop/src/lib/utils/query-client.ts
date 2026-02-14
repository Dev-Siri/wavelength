import { PUBLIC_BACKEND_URL } from "$env/static/public";

import type { z } from "zod";

import { WAVELENGTH_PLATFORM_KEY } from "$lib/constants/keys";
import userStore from "$lib/stores/user.svelte";
import { apiResponseSchema, type ApiResponse } from "./validation/api-response";

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
    await fetch(`${PUBLIC_BACKEND_URL}/diagnostics/report-error`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        error: JSON.stringify(error),
        source: "queryClient",
        platform: WAVELENGTH_PLATFORM_KEY,
      }),
    });
    throw error;
  }
}

function createQueryClient(baseUrl: string) {
  return async <T extends z.ZodTypeAny>(
    endpoint: string,
    dataSchema: T,
    options: Partial<Options> = {},
  ) => queryClient<T>(baseUrl, endpoint, dataSchema, options);
}

export const backendClient = createQueryClient(PUBLIC_BACKEND_URL);
