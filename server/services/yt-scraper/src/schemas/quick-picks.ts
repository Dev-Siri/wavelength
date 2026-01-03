import { z } from "zod";
import { thumbnailSchema } from "./thumbnail";

export const quickPicksSchema = z.object({
  type: z.literal("MusicCarouselShelf"),
  contents: z.array(
    z.object({
      type: z.literal("MusicResponsiveListItem"),
      item_type: z.string(),
      id: z.string(),
      title: z.string(),
      artists: z.array(
        z.object({
          name: z.string(),
          channel_id: z.string(),
        })
      ),
      album: z
        .object({
          id: z.string(),
          name: z.string(),
        })
        .nullish(),
      thumbnail: z.object({
        type: z.literal("MusicThumbnail"),
        contents: z.array(thumbnailSchema),
      }),
    })
  ),
});
