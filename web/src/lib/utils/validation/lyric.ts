import { z } from "zod";

export const lyricSchema = z.object({
  text: z.string(),
  startMs: z.number(),
  durMs: z.number(),
});
export const lyricsSchema = z.array(lyricSchema);

export type Lyric = z.infer<typeof lyricSchema>;
export type Lyrics = z.infer<typeof lyricsSchema>;
