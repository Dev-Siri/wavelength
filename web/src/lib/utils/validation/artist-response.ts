import { z } from "zod";
import { artistSongSchema } from "./music-track";

export const artistResponseSchema = z.object({
  title: z.string(),
  description: z.string(),
  subscriberCount: z.string(),
  topSongs: z.array(artistSongSchema),
});

export const artistExtraResponseSchema = z.object({
  thumbnail: z.string(),
});
