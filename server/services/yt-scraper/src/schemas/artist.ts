import { z } from "zod";

import { thumbnailContentSchema, thumbnailSchema } from "./thumbnail";

export const embeddedArtistSchema = z.object({
  name: z.string(),
  channel_id: z.string(),
});

export const searchArtistSchema = z.array(
  z.object({
    type: z.literal("MusicResponsiveListItem"),
    thumbnail: thumbnailSchema,
    id: z.string(),
    name: z.string(),
    subtitle: z.object({
      text: z.string(),
    }),
  })
);

export const artistDetailsResponseHeaderSchema = z.object({
  type: z.literal("MusicImmersiveHeader"),
  thumbnail: thumbnailSchema,
  title: z.object({
    text: z.string(),
  }),
  description: z
    .object({
      text: z.string().optional(),
    })
    .optional(),
  subscription_button: z.object({
    channel_id: z.string(),
    subscribe_accessibility_label: z.string(),
  }),
});

export const artistDetailsResponseTopSongsSchema = z.array(
  z.object({
    type: z.literal("MusicResponsiveListItem"),
    flex_columns: z.array(
      z.object({
        type: z.literal("MusicResponsiveListItemFlexColumn"),
        title: z.object({
          text: z.string(),
          runs: z.array(
            z
              .object({
                endpoint: z
                  .object({
                    type: z.literal("NavigationEndpoint"),
                    payload: z
                      .object({
                        browseId: z.string().optional(),
                      })
                      .optional(),
                  })
                  .optional(),
              })
              .optional()
          ),
        }),
      })
    ),
    thumbnail: thumbnailSchema,
    id: z.string(),
    title: z.string(),
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

export const artistDetailsResponseAlbumsSchema = z.array(
  z.object({
    type: z.literal("MusicTwoRowItem"),
    title: z.object({
      text: z.string(),
    }),
    subtitle: z.object({
      text: z.string(),
    }),
    id: z.string(),
    year: z.string().optional(),
    thumbnail: thumbnailContentSchema,
  })
);
