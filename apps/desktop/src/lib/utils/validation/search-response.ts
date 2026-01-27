import { z } from "zod";

import { albumSchema } from "./albums";
import { artistSchema } from "./artist";
import { musicTrackSchema } from "./music-track";

export const musicSearchResponseSchema = z.object({
  tracks: z.array(musicTrackSchema).optional(),
});

export const artistSearchResponseSchema = z.object({
  artists: z.array(artistSchema).optional(),
});

export const albumSearchResponseSchema = z.object({
  albums: z.array(albumSchema).optional(),
});
