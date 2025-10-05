import { z } from "zod";

export const playlistTrackSchema = z.object({
  playlistId: z.string(),
  playlistTrackId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  positionInPlaylist: z.number(),
  isExplicit: z.boolean(),
  author: z.string(),
  duration: z.string(),
  videoId: z.string(),
  videoType: z.enum(["track", "uvideo"]),
});
export const playlistTracksSchema = z.array(playlistTrackSchema);

export const playlistTrackLengthSchema = z.object({
  songCount: z.number(),
  songDurationSecond: z.number(),
});

export type PlaylistTrack = z.infer<typeof playlistTrackSchema>;
export type PlaylistTrackLength = z.infer<typeof playlistTrackLengthSchema>;
export type VideoType = PlaylistTrack["videoType"];
