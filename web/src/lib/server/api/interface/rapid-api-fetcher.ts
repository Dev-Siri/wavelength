import { PRIVATE_RAPID_API_HOST, PRIVATE_RAPID_API_KEY } from "$env/static/private";

import { RAPID_API_URL } from "$lib/constants/urls.js";
import queryClient from "$lib/utils/query-client.js";

interface Options {
  searchParams?: Record<string, unknown>;
}

export default async function fetchFromRapidApi<T>(path: `/${string}`, { searchParams }: Options) {
  const response = await queryClient<T>(RAPID_API_URL, path, {
    searchParams,
    headers: {
      "X-RapidApi-Key": PRIVATE_RAPID_API_KEY,
      "X-RapidApi-Host": PRIVATE_RAPID_API_HOST,
    },
  });

  return response;
}
