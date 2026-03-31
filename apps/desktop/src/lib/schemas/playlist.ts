import { z } from "zod";

import { embeddedAlbumSchema, embeddedArtistSchema } from "./embedded";
import { musicTrackSchema } from "./music-track";

export const playlistSchema = z.object({
  playlistId: z.string(),
  name: z.string(),
  authorGoogleEmail: z.string(),
  authorName: z.string(),
  authorImage: z.string(),
  coverImage: z.string().nullish(),
  isPublic: z.boolean(),
});
export const playlistsSchema = z.object({
  playlists: z.array(playlistSchema).optional(),
});

export const playlistSongRecommendationsSchema = z.object({
  continuationToken: z.string(),
  tracks: z.array(musicTrackSchema),
});

export const playlistVideoTypeSchema = z.enum(["VIDEO_TYPE_TRACK", "VIDEO_TYPE_UVIDEO"]);

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
  videoType: playlistVideoTypeSchema,
});
export const playlistTracksSchema = z.object({
  playlistTracks: z.array(playlistTrackSchema).optional(),
});
export const playlistTrackLikedStatusSchema = z.record(z.string(), z.boolean());
export const playlistTracksLikedStatusSchema = z.object({
  likedTracks: playlistTrackLikedStatusSchema,
});

export type PlaylistTrack = z.infer<typeof playlistTrackSchema>;
export type PlaylistTrackLikedStatus = z.infer<typeof playlistTrackLikedStatusSchema>;
export type PlaylistVideoType = z.infer<typeof playlistVideoTypeSchema>;
export type Playlist = z.infer<typeof playlistSchema>;
export type Playlists = z.infer<typeof playlistsSchema>;
export type PlaylistSongRecommendations = z.infer<typeof playlistSongRecommendationsSchema>;
