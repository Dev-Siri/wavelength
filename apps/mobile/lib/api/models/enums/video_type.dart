import "package:hive/hive.dart";

part "video_type.g.dart";

@HiveType(typeId: 15)
enum VideoType {
  @HiveField(0)
  unspecified,
  @HiveField(1)
  track,
  @HiveField(2)
  uvideo,
}

extension VideoTypeParser on VideoType {
  static VideoType fromGrpc(String value) {
    switch (value) {
      case "VIDEO_TYPE_TRACK":
        return VideoType.track;
      case "VIDEO_TYPE_UVIDEO":
        return VideoType.uvideo;
      case "VIDEO_TYPE_UNSPECIFIED":
        return VideoType.unspecified;
    }
    return VideoType.unspecified;
  }

  String toGrpc() {
    switch (this) {
      case VideoType.track:
        return "VIDEO_TYPE_TRACK";
      case VideoType.uvideo:
        return "VIDEO_TYPE_UVIDEO";
      case VideoType.unspecified:
        return "VIDEO_TYPE_UNSPECIFIED";
    }
  }
}
