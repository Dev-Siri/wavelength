import { z } from "zod";

import { embeddedAlbumSchema, embeddedArtistSchema } from "./embedded";

export const quickPicksResponseSchema = z.object({
  quickPicks: z.array(
    z.object({
      videoId: z.string(),
      title: z.string(),
      thumbnail: z.string(),
      artists: z.array(embeddedArtistSchema),
      album: embeddedAlbumSchema.nullish(),
    }),
  ),
});

export type QuickPick = z.infer<typeof quickPicksResponseSchema>["quickPicks"][number];
