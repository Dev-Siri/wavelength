import { z } from "zod";

export const musicTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  duration: z.string(),
  isExplicit: z.boolean().optional(),
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

export const automixTracksResponse = z.object({
  tracks: z.array(musicTrackSchema),
});

export type MusicTrack = z.infer<typeof musicTrackSchema>;
