import { z } from "zod";

export const musicTrackStatsSchema = z.object({
  viewCount: z.string(),
  likeCount: z.string(),
  commentCount: z.string(),
});

export const musicTrackStatsResponseSchema = z.object({
  musicTrackStats: musicTrackStatsSchema,
});
