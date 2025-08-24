import type { QuickPickMusic } from "../types.js";
import type { CommonOptions } from "./types.js";

import { DEFAULT_REGION } from "$lib/constants/countries.js";
import fetchFromRapidApi from "../rapid-api-fetcher.js";

export interface QuickPicksResponse {
  error: boolean;
  results: QuickPickMusic[];
}

export default async function getQuickPicks({ gl = DEFAULT_REGION }: CommonOptions) {
  const response = await fetchFromRapidApi<QuickPicksResponse>("/recommend", {
    searchParams: { gl },
  });

  return response;
}
