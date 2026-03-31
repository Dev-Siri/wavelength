import { z } from "zod";

export const searchSuggestedLinkSchema = z.object({
  thumbnail: z.string(),
  title: z.string(),
  subtitle: z.string(),
  browseId: z.string(),
  type: z.string(),
});

export const searchRecommendationsSchema = z.object({
  matchingQueries: z.array(z.string()),
  matchingLinks: z.array(searchSuggestedLinkSchema).optional(),
});

export type SearchRecommendations = z.infer<typeof searchRecommendationsSchema>;
