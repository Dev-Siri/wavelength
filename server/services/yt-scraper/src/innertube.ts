import { Innertube } from "youtubei.js";

const REFRESH_MS = 15 * 60e3;

let innertube: Innertube | null = null;
let lastInit = 0;

export async function getYtClient(gl?: string) {
  if (!innertube || Date.now() - lastInit > REFRESH_MS) {
    innertube = await Innertube.create({
      fetch,
      location: gl,
      device_category: "desktop",
    });
    lastInit = Date.now();
  }

  return innertube;
}

export const getYtMusicClient = (gl?: string) =>
  getYtClient(gl).then((client) => client.music);
