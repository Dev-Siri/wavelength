import { z } from "zod";

import { embeddedAlbumSchema } from "./album";
import { embeddedArtistSchema } from "./artist";
import { thumbnailSchema } from "./thumbnail";

export const quickPicksSchema = z.object({
  type: z.literal("MusicCarouselShelf"),
  contents: z.array(
    z.object({
      type: z.literal("MusicResponsiveListItem"),
      item_type: z.string(),
      id: z.string(),
      title: z.string(),
      artists: z.array(embeddedArtistSchema),
      album: embeddedAlbumSchema,
      thumbnail: thumbnailSchema,
    })
  ),
});
