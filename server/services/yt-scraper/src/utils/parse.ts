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
