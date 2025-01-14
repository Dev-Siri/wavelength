interface Lyric {
  text: string;
  startMs: number;
  durMs: number;
}

export type LyricsResponse = Lyric[];
