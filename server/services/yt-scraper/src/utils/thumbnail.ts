import { z } from "zod";

import type { thumbnailSchema } from "../schemas/thumbnail";

export function getHighestQualityThumbnail(
  thumbnailField: z.infer<typeof thumbnailSchema>
) {
  const [thumbnail] = thumbnailField.contents.toSorted(
    (a, b) => b.height - a.height
  );
  return thumbnail;
}
