import { z } from "zod";
import { artistSongSchema } from "./music-track";

export const artistResponseSchema = z.object({
  title: z.string(),
  description: z.string(),
  thumbnail: z.string(),
  subscriberCount: z.string(),
  songs: z
    .object({
      browseId: z.string(),
      titleHeader: z.string(),
      contents: z.array(artistSongSchema),
    })
    .nullish(),
});

export const artistExtraResponseSchema = z.object({
  thumbnail: z.string(),
});
