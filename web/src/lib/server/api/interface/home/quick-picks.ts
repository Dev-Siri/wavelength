import { DEFAULT_REGION } from "$lib/constants/countries";
import fetchFromRapidApi from "../rapid-api-fetcher";

import type { QuickPickMusic } from "../types";
import type { CommonOptions } from "./types";

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
