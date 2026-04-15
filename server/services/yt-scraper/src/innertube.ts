import { Innertube, Log, type SessionOptions } from "youtubei.js";

Log.setLevel(
  process.env.NODE_ENV === "production" ? Log.Level.NONE : Log.Level.DEBUG,
);

export async function getYtClient(
  gl?: string,
  configOverwrite?: SessionOptions,
) {
  return await Innertube.create({
    fetch,
    location: gl,
    retrieve_player: true,
    device_category: "desktop",
    ...configOverwrite,
  });
}

export const getYtMusicClient = (
  gl?: string,
  configOverwrite?: SessionOptions,
) => getYtClient(gl, configOverwrite).then((client) => client.music);
