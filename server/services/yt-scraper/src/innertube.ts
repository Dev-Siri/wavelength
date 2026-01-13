import { ClientType, Innertube } from "youtubei.js";

import { env } from "@/config.js";

const FAKE_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36";
const REFRESH_MS = 15 * 60e3;

const cookie = env.COOKIE && atob(env.COOKIE);

let innertube: Innertube | null = null;
let lastInit = 0;

export async function getYtMusicClient(
  gl?: string,
  { passCookies } = { passCookies: false }
) {
  if (!innertube || Date.now() - lastInit > REFRESH_MS) {
    innertube = await Innertube.create({
      fetch,
      location: gl,
      user_agent: FAKE_AGENT,
      cookie: passCookies ? cookie : undefined,
      visitor_data: env.VISITOR_DATA,
      client_type: ClientType.IOS,
    });
    lastInit = Date.now();
  }

  return innertube.music;
}
