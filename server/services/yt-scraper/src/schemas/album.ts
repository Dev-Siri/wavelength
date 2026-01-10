import { z } from "zod";
import { thumbnailSchema } from "./thumbnail";

export const embeddedAlbumSchema = z
  .object({
    id: z.string(),
    name: z.string(),
  })
  .optional();

export const searchAlbumSchema = z.array(
  z.object({
    type: z.literal("MusicResponsiveListItem"),
    id: z.string(),
    title: z.string(),
    year: z.string(),
    author: z
      .object({
        name: z.string(),
        channel_id: z.string(),
      })
      .optional(),
    flex_columns: z.array(
      z.object({
        type: z.literal("MusicResponsiveListItemFlexColumn"),
        title: z.object({
          text: z.string(),
        }),
      })
    ),
    thumbnail: thumbnailSchema,
  })
);

export const albumHeaderSchema = z.object({
  type: z.literal("MusicResponsiveHeader"),
  thumbnail: thumbnailSchema,
  title: z.object({
    text: z.string(),
  }),
  subtitle: z.object({
    text: z.string(),
  }),
  second_subtitle: z.object({
    text: z.string(),
  }),
  strapline_text_one: z.object({
    text: z.string(),
    endpoint: z.object({
      type: z.literal("NavigationEndpoint"),
      payload: z.object({
        browseId: z.string(),
      }),
    }),
  }),
});

export const albumContents = z.array(
  z.object({
    type: z.literal("MusicResponsiveListItem"),
    index: z.object({
      text: z.string(),
    }),
    id: z.string(),
    title: z.string(),
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
);
