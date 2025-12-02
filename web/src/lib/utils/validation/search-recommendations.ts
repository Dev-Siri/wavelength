import { z } from "zod";

export const searchSuggestedLinkMetaSchema = z.object({
  type: z.string(),
  authorOrAlbum: z.string(),
  playsOrAlbumRelease: z.string(),
});

export const searchSuggestedLinkSchema = z.object({
  meta: searchSuggestedLinkMetaSchema,
  thumbnail: z.string(),
  title: z.string(),
  subtitle: z.string(),
  browseId: z.string(),
  isExplicit: z.boolean(),
  type: z.string(),
});

export const searchRecommendationsSchema = z.object({
  matchingQueries: z.array(z.string()),
  matchingLinks: z.array(searchSuggestedLinkSchema),
});

export type SearchRecommendations = z.infer<typeof searchRecommendationsSchema>;
