import { z } from "zod";

export const thumbnailContentSchema = z.array(
  z.object({
    url: z.string(),
    height: z.number(),
    width: z.number(),
  })
);

export const thumbnailSchema = z.object({
  type: z.literal("MusicThumbnail"),
  contents: thumbnailContentSchema,
});
