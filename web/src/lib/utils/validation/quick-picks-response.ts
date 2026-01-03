import { z } from "zod";

const quickPickSubInfoSchema = z.object({
  title: z.string(),
  browseId: z.string(),
});

export const quickPicksResponseSchema = z.object({
  quickPicks: z.array(
    z.object({
      videoId: z.string(),
      title: z.string(),
      thumbnail: z.string(),
      artists: z.array(quickPickSubInfoSchema),
      album: quickPickSubInfoSchema.nullish(),
    }),
  ),
});
