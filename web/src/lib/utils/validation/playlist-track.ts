import { z } from "zod";

export const videoTypeSchema = z.enum(["track", "uvideo"]);
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
  videoType: videoTypeSchema,
});
export const playlistTracksSchema = z.array(playlistTrackSchema);

export type PlaylistTrack = z.infer<typeof playlistTrackSchema>;
export type VideoType = z.infer<typeof videoTypeSchema>;
