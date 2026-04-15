import { z } from "zod";

import { embeddedAlbumSchema, embeddedArtistSchema } from "./embedded";
import { musicTrackSchema } from "./music-track";

const quickPickSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  artists: z.array(embeddedArtistSchema),
  album: embeddedAlbumSchema.nullish(),
});

export const quickPicksResponseSchema = z.object({
  quickPicks: z.array(quickPickSchema).optional(),
});

export const recentlyPlayedSchema = z.object({
  tracks: z.array(musicTrackSchema).optional(),
});

export type QuickPick = z.infer<typeof quickPickSchema>;
