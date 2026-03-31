import { z } from "zod";

import { albumTypeSchema } from "./album";
import { embeddedAlbumSchema, embeddedArtistSchema } from "./embedded";

export const searchArtistSchema = z.object({
  title: z.string(),
  thumbnail: z.string(),
  browseId: z.string(),
  audience: z.string(),
});

export const artistTopSongTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  duration: z.string(),
  thumbnail: z.string(),
  playCount: z.string(),
  isExplicit: z.boolean(),
  artists: z.array(embeddedArtistSchema),
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

export const artistSchema = z.object({
  browseId: z.string(),
  title: z.string(),
  description: z.string().optional(),
  thumbnail: z.string(),
  audience: z.string(),
  topSongs: z.array(artistTopSongTrackSchema),
  albums: z.array(artistAlbumSchema),
  singlesAndEps: z.array(artistAlbumSchema),
});

export const artistResponseSchema = z.object({
  artist: artistSchema,
});

export const followedArtistResponseSchema = z.object({
  artists: z.array(followedArtistSchema).optional(),
});

export type FollowedArtist = z.infer<typeof followedArtistSchema>;
export type Artist = z.infer<typeof artistSchema>;
export type ArtistTopSong = z.infer<typeof artistTopSongTrackSchema>;
export type ArtistAlbum = z.infer<typeof artistAlbumSchema>;
export type SearchArtist = z.infer<typeof searchArtistSchema>;
