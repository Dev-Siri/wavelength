import z from "zod";

export const embeddedArtistSchema = z.object({
  title: z.string(),
  browseId: z.string(),
});

export const embeddedAlbumSchema = z.object({
  title: z.string(),
  browseId: z.string(),
});

export type EmbeddedArtist = z.infer<typeof embeddedArtistSchema>;
export type EmbeddedAlbum = z.infer<typeof embeddedAlbumSchema>;
