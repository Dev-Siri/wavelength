import { z } from "zod";

import { embeddedArtistSchema } from "./embedded";

export const albumTypeSchema = z.enum(["ALBUM_TYPE_ALBUM", "ALBUM_TYPE_EP", "ALBUM_TYPE_SINGLE"]);

export const albumTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  duration: z.string(),
  isExplicit: z.boolean(),
  positionInAlbum: z.number(),
  artists: z.array(embeddedArtistSchema),
});

export const albumSchema = z.object({
  albumId: z.string(),
  albumType: albumTypeSchema,
  title: z.string(),
  thumbnail: z.string(),
  artist: embeddedArtistSchema,
  releaseDate: z.string(),
});

export const albumDetailsSchema = z.object({
  album: z.object({
    title: z.string(),
    description: z.string().optional(),
    release: z.string(),
    albumType: albumTypeSchema,
    artist: embeddedArtistSchema,
    cover: z.string(),
    totalSongCount: z.number(),
    totalDuration: z.string(),
    albumTracks: z.array(albumTrackSchema),
  }),
});

export const savedAlbumSchema = z.object({
  saverEmail: z.string(),
  albumId: z.string(),
  title: z.string(),
  albumCover: z.string(),
  albumSongCount: z.number(),
  albumDuration: z.string(),
  albumAuthor: z.string(),
  albumType: albumTypeSchema,
});

export const albumLiveCoverSchema = z.object({
  liveAlbumCoverUri: z.string().optional(),
});
export const savedAlbumResponseSchema = z.object({
  albums: z.array(savedAlbumSchema).optional(),
});
export const isAlbumLosslessSchema = z.object({
  isLossless: z.boolean(),
});
export const isAlbumSavedSchema = z.object({
  isSaved: z.boolean(),
});
export const albumSaveResponseSchema = z.object({
  saveType: z.enum(["ALBUM_SAVE_TYPE_ADD_SAVE", "ALBUM_SAVE_TYPE_REMOVE_SAVE"]),
});

export type Album = z.infer<typeof albumSchema>;
export type AlbumTrack = z.infer<typeof albumTrackSchema>;
export type AlbumDetails = z.infer<typeof albumDetailsSchema>;
export type AlbumType = z.infer<typeof albumTypeSchema>;
export type SavedAlbum = z.infer<typeof savedAlbumSchema>;
export type AlbumLiveCover = z.infer<typeof albumLiveCoverSchema>;
export type IsAlbumLossless = z.infer<typeof isAlbumLosslessSchema>;
