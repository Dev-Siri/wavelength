import { z } from "zod";

export const syllableSchema = z.object({
  text: z.string(),
  part: z.boolean().optional(),
  timestamp: z.coerce.number(),
  endtime: z.coerce.number(),
  romanizedText: z.string().optional(),
  lineSynced: z.boolean().optional(),
});

export const lyricsLineSchema = z.object({
  text: z.array(syllableSchema).optional(),
  background: z.boolean().optional(),
  backgroundText: z.array(syllableSchema).optional(),
  oppositeTurn: z.boolean().optional(),
  timestamp: z.coerce.number(),
  endtime: z.coerce.number(),
  isWordSynced: z.boolean().optional(),
  alignment: z.enum(["ALIGNMENT_DIRECTION_START", "ALIGNMENT_DIRECTION_END"]).optional(),
  songPart: z.string().optional(),
  romanizedText: z.string().optional(),
  translation: z.string().optional(),
});

export const lyricsSchema = z.object({
  source: z.string(),
  lines: z.array(lyricsLineSchema),
});

export const romanizedLyricsSchema = z.object({
  romanizedLines: z.array(lyricsLineSchema),
});

export const translatedLyricsSchema = z.object({
  translations: z.array(z.string()),
});

export type Lyrics = z.infer<typeof lyricsSchema>;

export type Syllable = z.infer<typeof syllableSchema>;
export type LyricsLine = z.infer<typeof lyricsLineSchema>;
