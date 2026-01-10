import { z } from "zod";

import { thumbnailSchema } from "./thumbnail";

const suggestionRunSchema = z.object({
  text: z.string(),
  bold: z.boolean(),
  bracket: z.boolean(),
  deemphasize: z.boolean(),
  italics: z.boolean(),
  strikethrough: z.boolean(),
  error_underline: z.boolean(),
  underline: z.boolean(),
});

// Search suggestions are just a string[] of matching queries.
export const searchSuggestionSchema = z.object({
  type: z.literal("SearchSuggestion"),
  icon_type: z.string(),
  suggestion: z.object({
    text: z.string(),
    rtl: z.boolean(),
    runs: z.array(suggestionRunSchema),
  }),
});

// Search suggestion links are songs/videos that YouTube Music recommends that match the query.
export const searchSuggestionColumnSchema = z.object({
  type: z.literal("MusicResponsiveListItemFlexColumn"),
  title: z.object({
    text: z.string(),
    rtl: z.boolean(),
    runs: z.array(suggestionRunSchema),
  }),
});

export const searchSuggestionLinkSchema = z.object({
  type: z.literal("MusicResponsiveListItem"),
  flex_columns: z.array(searchSuggestionColumnSchema),
  item_type: z.string(),
  id: z.string(),
  thumbnail: thumbnailSchema,
});
