import { z } from "zod";

import { albumSchema } from "./albums";
import { artistSongSchema } from "./music-track";

export const artistResponseSchema = z.object({
  title: z.string(),
  description: z.string(),
  subscriberCount: z.string(),
  topSongs: z.array(artistSongSchema),
  albums: z.array(albumSchema),
  singlesAndEps: z.array(albumSchema),
});

export const artistExtraResponseSchema = z.object({
  thumbnail: z.string(),
});
