import { z } from "zod";

export const artistSchema = z.object({
  title: z.string(),
  thumbnail: z.string(),
  author: z.string(),
  browseId: z.string(),
  subscriberText: z.string(),
  isExplicit: z.boolean(),
});

export type Artist = z.infer<typeof artistSchema>;
