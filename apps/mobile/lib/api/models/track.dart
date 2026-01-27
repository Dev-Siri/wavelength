import "package:flutter/foundation.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/embedded.dart";

part "track.g.dart";

@immutable
@HiveType(typeId: 7)
class Track {
  @HiveField(0)
  final String videoId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnail;
  @HiveField(3)
  final List<EmbeddedArtist> artists;
  @HiveField(4)
  final int duration;
  @HiveField(5)
  final bool isExplicit;
  @HiveField(6)
  final EmbeddedAlbum? album;

  const Track({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.artists,
    required this.duration,
    required this.isExplicit,
    required this.album,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final album = json["album"];
    return Track(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      artists: (json["artists"] as List)
          .map((artist) => EmbeddedArtist.fromJson(artist))
          .toList(),
      duration: int.parse(json["duration"]),
      isExplicit: json["isExplicit"] as bool,
      album: album != null ? EmbeddedAlbum.fromJson(album) : null,
    );
  }
}
