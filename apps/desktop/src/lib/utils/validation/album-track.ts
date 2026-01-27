import { z } from "zod";

export const albumTrackSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  duration: z.string(),
  isExplicit: z.boolean(),
  positionInAlbum: z.number(),
});
