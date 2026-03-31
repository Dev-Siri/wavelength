import { createQuery } from "@tanstack/svelte-query";
import { z } from "zod";

import { svelteQueryKeys } from "$lib/constants/keys";
import { backendClient } from "$lib/utils/query-client";

export default function useRegionQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.region,
    queryFn: () => backendClient("/region", z.string()),
  }));
}
