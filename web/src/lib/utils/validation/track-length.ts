import { z } from "zod";

export const trackLengthSchema = z.object({
  songCount: z.string(),
  songDurationSecond: z.string(),
});

export const playlistTracksLengthSchema = z.object({
  playlistTracksLength: trackLengthSchema,
});

export const likedTracksLengthSchema = z.object({
  likedTracksLength: trackLengthSchema,
});

export const musicTrackDurationSchema = z.object({
  durationSeconds: z.number(),
});

export type TrackLength = z.infer<typeof trackLengthSchema>;
export type MusicTrackDuration = z.infer<typeof musicTrackDurationSchema>;
