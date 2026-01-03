import { z } from "zod";

import type { thumbnailSchema } from "../schemas/thumbnail";

export function getHighestQualityThumbnail(
  thumbnails: z.infer<typeof thumbnailSchema>[]
) {
  const [thumbnail] = thumbnails.toSorted((a, b) => b.height - a.height);
  return thumbnail;
}
