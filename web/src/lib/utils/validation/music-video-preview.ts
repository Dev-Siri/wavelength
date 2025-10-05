import { z } from "zod";

export const musicVideoPreviewSchema = z.object({
  videoId: z.string(),
});
