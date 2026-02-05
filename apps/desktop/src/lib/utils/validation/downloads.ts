import { z } from "zod";

import { musicTrackSchema } from "./music-track";

export const downloadMetaSchema = z.array(musicTrackSchema);

export type DownloadMeta = z.infer<typeof downloadMetaSchema>;
