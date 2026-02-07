import { z } from "zod";

import { embeddedAlbumSchema } from "./albums";
import { embeddedArtistSchema } from "./artist";

export const videoTypeSchema = z.enum(["VIDEO_TYPE_TRACK", "VIDEO_TYPE_UVIDEO"]);

export const playlistTrackSchema = z.object({
  playlistId: z.string(),
  playlistTrackId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  positionInPlaylist: z.number(),
  isExplicit: z.boolean(),
  album: z.optional(embeddedAlbumSchema),
  artists: z.array(embeddedArtistSchema),
  duration: z.string(),
  videoId: z.string(),
  videoType: videoTypeSchema,
});
export const playlistTracksSchema = z.object({
  playlistTracks: z.array(playlistTrackSchema),
});

export type PlaylistTrack = z.infer<typeof playlistTrackSchema>;
export type VideoType = z.infer<typeof videoTypeSchema>;
