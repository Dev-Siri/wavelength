import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";

part "liked_track.g.dart";

@HiveType(typeId: 3)
class LikedTrack {
  @HiveField(0)
  final String likeId;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String thumbnail;
  @HiveField(4)
  final bool isExplicit;
  @HiveField(5)
  final List<EmbeddedArtist> artists;
  @HiveField(6)
  final int duration;
  @HiveField(7)
  final String videoId;
  @HiveField(8)
  final VideoType videoType;
  @HiveField(9)
  final EmbeddedAlbum? album;

  LikedTrack({
    required this.likeId,
    required this.email,
    required this.title,
    required this.thumbnail,
    required this.isExplicit,
    required this.artists,
    required this.duration,
    required this.videoId,
    required this.videoType,
    required this.album,
  });

  factory LikedTrack.fromJson(Map<String, dynamic> json) {
    final album = json["album"];
    return LikedTrack(
      likeId: json["likeId"] as String,
      email: json["email"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      isExplicit: json["isExplicit"] as bool,
      artists: (json["artists"] as List)
          .map((artist) => EmbeddedArtist.fromJson(artist))
          .toList(),
      duration: int.parse(json["duration"]),
      videoId: json["videoId"] as String,
      videoType: VideoTypeParser.fromGrpc(json["videoType"]),
      album: album == null ? null : EmbeddedAlbum.fromJson(album),
    );
  }
}
