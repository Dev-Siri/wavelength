import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { getDownloads } from "$lib/ipc/download";

export default function useDownloadsQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.downloads,
    queryFn: getDownloads,
  }));
}
