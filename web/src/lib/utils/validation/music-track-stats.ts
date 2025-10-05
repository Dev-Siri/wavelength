import { z } from "zod";

export const musicTrackStatsSchema = z.object({
  viewCount: z.number(),
  likeCount: z.number(),
  commentCount: z.number(),
});
