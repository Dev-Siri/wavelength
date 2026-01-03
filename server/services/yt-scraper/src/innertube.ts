import { Innertube } from "youtubei.js";

export const innertube = await Innertube.create();

// General-purpose client.
export const music = innertube.music;
// Region-specific client.
export async function musicPref(gl: string) {
  const regionalInnertube = await Innertube.create({ location: gl });
  return regionalInnertube.music;
}
