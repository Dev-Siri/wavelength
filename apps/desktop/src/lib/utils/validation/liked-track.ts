import { z } from "zod";

import { embeddedArtistSchema } from "./artist";
import { videoTypeSchema } from "./playlist-track";

export const likedTrackSchema = z.object({
  likeId: z.string(),
  email: z.string(),
  title: z.string(),
  thumbnail: z.string(),
  isExplicit: z.boolean(),
  duration: z.string(),
  videoId: z.string(),
  videoType: videoTypeSchema,
  artists: z.array(embeddedArtistSchema),
});

export const likedTracksSchema = z.object({
  likedTracks: z.array(likedTrackSchema),
});

export type LikedTrack = z.infer<typeof likedTrackSchema>;
