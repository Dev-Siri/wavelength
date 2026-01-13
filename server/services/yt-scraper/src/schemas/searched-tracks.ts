import { z } from "zod";

import { embeddedAlbumSchema } from "./album.js";
import { embeddedArtistSchema } from "./artist.js";
import { thumbnailSchema } from "./thumbnail.js";

export const searchedTracksSchema = z.object({
  type: z.literal("MusicShelf"),
  contents: z.array(
    z.object({
      type: z.literal("MusicResponsiveListItem"),
      flex_columns: z.array(
        z.object({
          type: z.literal("MusicResponsiveListItemFlexColumn"),
          title: z.object({
            text: z.string(),
            rtl: z.boolean(),
          }),
        })
      ),
      thumbnail: thumbnailSchema,
      id: z.string(),
      album: embeddedAlbumSchema,
      artists: z.array(embeddedArtistSchema),
      duration: z.object({
        text: z.string(),
        seconds: z.number(),
      }),
      badges: z
        .array(
          z.object({
            type: z.literal("MusicInlineBadge"),
            icon_type: z.string(),
          })
        )
        .optional(),
    })
  ),
});
