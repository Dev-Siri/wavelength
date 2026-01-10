import { z } from "zod";

export const embeddedArtistSchema = z.object({
  title: z.string(),
  browseId: z.string(),
});

export const artistSchema = z.object({
  title: z.string(),
  thumbnail: z.string(),
  browseId: z.string(),
  audience: z.string(),
});

export type Artist = z.infer<typeof artistSchema>;
export type EmbeddedArtist = z.infer<typeof embeddedArtistSchema>;
