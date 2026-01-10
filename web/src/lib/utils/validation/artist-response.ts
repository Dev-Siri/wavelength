import { z } from "zod";

import { albumTypeSchema, embeddedAlbumSchema } from "./albums";

export const topSongTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  playCount: z.string(),
  isExplicit: z.boolean(),
  album: embeddedAlbumSchema.optional(),
});

export const followedArtistSchema = z.object({
  followId: z.string(),
  browseId: z.string(),
  followerEmail: z.string(),
  name: z.string(),
  thumbnail: z.string(),
});

export const artistAlbumSchema = z.object({
  albumId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  releaseDate: z.string(),
  albumType: albumTypeSchema,
});

export const artistResponseSchema = z.object({
  artist: z.object({
    browseId: z.string(),
    title: z.string(),
    description: z.string().optional(),
    thumbnail: z.string(),
    audience: z.string(),
    topSongs: z.array(topSongTrackSchema),
    albums: z.array(artistAlbumSchema),
    singlesAndEps: z.array(artistAlbumSchema),
  }),
});

export const followedArtistResponseSchema = z.object({
  artists: z.array(followedArtistSchema).optional(),
});

export type FollowedArtist = z.infer<typeof followedArtistSchema>;
