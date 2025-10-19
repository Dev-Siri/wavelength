import { del, get, set } from "idb-keyval";

import type { PersistedClient, Persister } from "@tanstack/svelte-query-persist-client";

export function createIDBPersister(key = "tanstackQueryCache"): Persister {
  return {
    persistClient: (client: PersistedClient) => set(key, client),
    restoreClient: () => get<PersistedClient>(key),
    removeClient: () => del(key),
  };
}
