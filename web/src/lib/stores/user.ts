import { writable } from "svelte/store";

import type { User } from "@auth/sveltekit";

export const user = writable<User | null>(null);
