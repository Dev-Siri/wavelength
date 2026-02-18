import { YTNodes } from "youtubei.js";

interface Thumbnail {
  height: number;
  width: number;
  url: string;
}

export function getHighestQualityThumbnail(
  thumbnail: YTNodes.MusicThumbnail | Thumbnail[],
) {
  const thumbnails =
    thumbnail instanceof YTNodes.MusicThumbnail
      ? thumbnail.contents
      : thumbnail;

  const [highestQualityThumbnail] = thumbnails.toSorted(
    (a, b) => b.height - a.height,
  );
  return highestQualityThumbnail;
}
