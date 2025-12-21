import { z } from "zod";

import { albumTrackSchema } from "./album-track";

export const albumSchema = z.object({
  albumId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  author: z.string(),
  releaseDate: z.string(),
  isExplicit: z.boolean(),
});

export const albumDetailsSchema = z.object({
  title: z.string(),
  albumType: z.string(),
  albumRelease: z.string(),
  albumAuthor: z.string(),
  albumCover: z.string(),
  albumDescription: z.string(),
  isExplicit: z.boolean(),
  albumTotalSong: z.string(),
  albumTotalDuration: z.string(),
  results: z.array(albumTrackSchema),
});

export type Album = z.infer<typeof albumSchema>;
export type AlbumDetails = z.infer<typeof albumDetailsSchema>;
