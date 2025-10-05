import { z } from "zod";

export const youtubeVideoSchema = z.object({
  videoId: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  author: z.string(),
});
export const youtubeVideosSchema = z.array(youtubeVideoSchema);

export type YouTubeVideo = z.infer<typeof youtubeVideoSchema>;
