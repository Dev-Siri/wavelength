import { z } from "zod";

export const trackLengthSchema = z.object({
  songCount: z.number(),
  songDurationSecond: z.number(),
});

export type TrackLength = z.infer<typeof trackLengthSchema>;
