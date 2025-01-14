import { writable } from "svelte/store";

import type { PlayList } from "$lib/db/schema";

export const playlists = writable<PlayList[]>([]);
