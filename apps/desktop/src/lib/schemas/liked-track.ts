import { z } from "zod";

import { embeddedAlbumSchema, embeddedArtistSchema } from "./embedded";
import { playlistVideoTypeSchema } from "./playlist";

export const likedTrackSchema = z.object({
  likeId: z.string(),
  email: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  isExplicit: z.boolean(),
  duration: z.string(),
  videoId: z.string(),
  videoType: playlistVideoTypeSchema,
  artists: z.array(embeddedArtistSchema),
  album: z.optional(embeddedAlbumSchema),
});

export const likedTracksSchema = z.object({
  likedTracks: z.array(likedTrackSchema),
});

export type LikedTrack = z.infer<typeof likedTrackSchema>;
