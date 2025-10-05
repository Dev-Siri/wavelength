import { z } from "zod";
import { artistSchema } from "./artist";
import { musicTrackSchema } from "./music-track";

export const musicSearchResponseSchema = z.object({
  result: z.array(musicTrackSchema),
  nextPageToken: z.string(),
});

export const artistSearchResponseSchema = z.object({
  result: z.array(artistSchema),
  nextPageToken: z.string().nullish(),
});
