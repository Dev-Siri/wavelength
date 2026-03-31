import type { AlbumType } from "../schemas/album";

export function compactify(
  statCount: string | number,
  type: "suffixed" | "shortened" = "suffixed",
) {
  const formatter = Intl.NumberFormat("en", {
    compactDisplay: "short",
    notation: type === "suffixed" ? "compact" : "standard",
    minimumFractionDigits: type === "suffixed" ? 2 : 0,
    maximumFractionDigits: type === "suffixed" ? 2 : 0,
  });

  return formatter.format(Number(statCount));
}

export function durationify(seconds: number) {
  const minutes = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);

  return `${minutes}:${secs.toString().padStart(2, "0")}`;
}

export function punctuatify(entities: string[]) {
  const listFormatter = new Intl.ListFormat("en-US", {
    style: "short",
  });
  return listFormatter.format(entities);
}

export function getReadableAlbumType(albumType: AlbumType) {
  switch (albumType) {
    case "ALBUM_TYPE_ALBUM":
      return "Album";
    case "ALBUM_TYPE_EP":
      return "EP";
    case "ALBUM_TYPE_SINGLE":
      return "Single";
  }
}
