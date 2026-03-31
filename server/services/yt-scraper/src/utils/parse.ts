import { AlbumType } from "@/gen/proto/common.js";

export function parseStringToAlbumType(albumType: string) {
  switch (albumType.toLowerCase()) {
    case "album":
      return AlbumType.ALBUM_TYPE_ALBUM;
    case "single":
      return AlbumType.ALBUM_TYPE_SINGLE;
    case "ep":
      return AlbumType.ALBUM_TYPE_EP;
    default:
      return AlbumType.ALBUM_TYPE_UNSPECIFIED;
  }
}

export function parseDuration(duration: string): number {
  if (!duration) return 0;

  const parts = duration.split(":").map((p) => parseInt(p, 10));

  if (parts.some((n) => Number.isNaN(n))) return 0;

  if (parts.length === 2) {
    const [minutes = 0, seconds = 0] = parts;
    return minutes * 60 + seconds;
  }

  if (parts.length === 3) {
    const [hours = 0, minutes = 0, seconds = 0] = parts;
    return hours * 3600 + minutes * 60 + seconds;
  }

  return 0;
}
