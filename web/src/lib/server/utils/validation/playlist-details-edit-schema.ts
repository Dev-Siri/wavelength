import { z } from "zod";

export const playlistDetailsEditSchema = z.object({
  name: z.string().max(255).min(3),
  coverImage: z.string().nullish(),
});
