import { z } from "zod";

export const baseMusicTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  author: z.string(),
});

export const musicTrackSchema = baseMusicTrackSchema.extend({
  duration: z.string(),
  isExplicit: z.boolean(),
});

export const artistSongSchema = baseMusicTrackSchema.extend({
  isExplicit: z.boolean(),
});

export type MusicTrack = z.infer<typeof musicTrackSchema>;
export type BaseMusicTrack = z.infer<typeof baseMusicTrackSchema>;
