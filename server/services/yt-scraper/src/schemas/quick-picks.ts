import { z } from "zod";

import { embeddedAlbumSchema } from "./album.js";
import { embeddedArtistSchema } from "./artist.js";
import { thumbnailSchema } from "./thumbnail.js";

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
