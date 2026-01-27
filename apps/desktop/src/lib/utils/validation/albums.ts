import { z } from "zod";

import { albumTrackSchema } from "./album-track";
import { embeddedArtistSchema } from "./artist";

export const albumTypeSchema = z.enum(["ALBUM_TYPE_ALBUM", "ALBUM_TYPE_EP", "ALBUM_TYPE_SINGLE"]);

export const embeddedAlbumSchema = z.object({
  title: z.string(),
  browseId: z.string(),
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
    release: z.string(),
    albumType: albumTypeSchema,
    artist: embeddedArtistSchema,
    cover: z.string(),
    totalSongCount: z.number(),
    totalDuration: z.string(),
    albumTracks: z.array(albumTrackSchema),
  }),
});

export type Album = z.infer<typeof albumSchema>;
export type AlbumDetails = z.infer<typeof albumDetailsSchema>;
export type EmbeddedAlbum = z.infer<typeof embeddedAlbumSchema>;
export type AlbumType = z.infer<typeof albumTypeSchema>;
