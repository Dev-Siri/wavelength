import { createContext } from "svelte";

import type GoogleCast from "../googleCast.svelte";

export const [getApplicationCastContext, setApplicationCastContext] =
  createContext<GoogleCast | null>();
