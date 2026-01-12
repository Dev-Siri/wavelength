import { Innertube } from "youtubei.js";

import { env } from "./config";

export const innertube = await Innertube.create({
  cookie: env.COOKIE && atob(env.COOKIE),
});

// General-purpose client.
export const music = innertube.music;
// Region-specific client.
export async function musicPref(gl: string) {
  const regionalInnertube = await Innertube.create({
    location: gl,
    cookie: env.COOKIE && atob(env.COOKIE),
  });
  return regionalInnertube.music;
}
