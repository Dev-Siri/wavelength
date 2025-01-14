import { z } from "zod";

export const playlistTrackAdditionSchema = z.object({
  author: z.string(),
  thumbnail: z.string(),
  duration: z.string(),
  isExplicit: z.boolean(),
  title: z.string().max(255),
  videoId: z.string().max(11),
  videoType: z.enum(["track", "uvideo"]),
});
