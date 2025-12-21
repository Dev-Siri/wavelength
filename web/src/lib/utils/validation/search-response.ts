import { z } from "zod";
import { albumSchema } from "./albums";
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

export const albumSearchResponseSchema = z.object({
  result: z.array(albumSchema),
  nextPageToken: z.string().nullish(),
});
