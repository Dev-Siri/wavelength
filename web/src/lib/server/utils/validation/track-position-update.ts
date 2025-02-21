import { z } from "zod";

export const trackPositionUpdateSchema = z.array(
  z.object({
    playlistTrackId: z.string(),
    newPos: z.number(),
  }),
);
