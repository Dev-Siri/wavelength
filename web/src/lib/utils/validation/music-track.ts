import { z } from "zod";

export const musicTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  duration: z.string(),
  isExplicit: z.boolean(),
  artists: z.array(
    z.object({
      title: z.string(),
      browseId: z.string(),
    }),
  ),
  album: z
    .object({
      title: z.string(),
      browseId: z.string(),
    })
    .optional(),
});

export type MusicTrack = z.infer<typeof musicTrackSchema>;
