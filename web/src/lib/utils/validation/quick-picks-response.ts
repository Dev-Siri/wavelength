import { z } from "zod";
import { baseMusicTrackSchema } from "./music-track";

export const quickPicksResponseSchema = z.array(baseMusicTrackSchema);
