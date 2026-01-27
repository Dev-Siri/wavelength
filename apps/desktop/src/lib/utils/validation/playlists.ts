import { z } from "zod";

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

export type Playlist = z.infer<typeof playlistSchema>;
export type Playlists = z.infer<typeof playlistsSchema>;
