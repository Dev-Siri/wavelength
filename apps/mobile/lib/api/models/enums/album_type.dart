import "package:hive/hive.dart";

part "album_type.g.dart";

@HiveType(typeId: 14)
enum AlbumType {
  @HiveField(0)
  unspecified,
  @HiveField(1)
  album,
  @HiveField(2)
  single,
  @HiveField(3)
  ep,
}

extension AlbumTypeParser on AlbumType {
  static AlbumType fromGrpc(String value) {
    switch (value) {
      case "ALBUM_TYPE_ALBUM":
        return AlbumType.album;
      case "ALBUM_TYPE_SINGLE":
        return AlbumType.single;
      case "ALBUM_TYPE_EP":
        return AlbumType.ep;
      case "ALBUM_TYPE_UNSPECIFIED":
        return AlbumType.unspecified;
    }
    return AlbumType.unspecified;
  }

  String toFormatted() {
    switch (this) {
      case AlbumType.album:
        return "Album";
      case AlbumType.single:
        return "Single";
      case AlbumType.ep:
        return "EP";
      case AlbumType.unspecified:
        return "";
    }
  }

  String toGrpc() {
    switch (this) {
      case AlbumType.album:
        return "ALBUM_TYPE_ALBUM";
      case AlbumType.single:
        return "ALBUM_TYPE_SINGLE";
      case AlbumType.ep:
        return "ALBUM_TYPE_EP";
      case AlbumType.unspecified:
        return "ALBUM_TYPE_UNSPECIFIED";
    }
  }
}
