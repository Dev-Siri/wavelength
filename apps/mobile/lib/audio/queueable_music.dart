import "package:flutter/foundation.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";

part "queueable_music.g.dart";

@HiveType(typeId: 25)
class QueueableMusic {
  @HiveField(0)
  final String videoId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnail;
  @HiveField(3)
  final int duration;
  @HiveField(4)
  final List<EmbeddedArtist> artists;
  @HiveField(5)
  final EmbeddedAlbum? album;
  @HiveField(6)
  final VideoType videoType;
  @HiveField(7)
  final bool isExplicit;

  const QueueableMusic({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.artists,
    required this.album,
    required this.videoType,
    required this.isExplicit,
  });

  Map<String, dynamic> toJson() {
    return {
      "videoId": videoId,
      "title": title,
      "thumbnail": thumbnail,
      "duration": duration,
      "artists": artists.map((artist) => artist.toJson()).toList(),
      "album": album?.toJson(),
      "videoType": videoType.toGrpc(),
      "isExplicit": isExplicit,
    };
  }

  @override
  String toString() =>
      "QueueableMusic(videoId: $videoId, title: $title, thumbnail: $thumbnail, duration: $duration, artists: $artists, album: $album, videoType: $videoType, isExplicit: $isExplicit)";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QueueableMusic &&
        other.videoId == videoId &&
        other.title == title &&
        other.thumbnail == thumbnail &&
        other.duration == duration &&
        listEquals(other.artists, artists) &&
        other.album == album &&
        other.videoType == videoType &&
        other.isExplicit == isExplicit;
  }

  @override
  int get hashCode => Object.hash(
    videoId,
    title,
    thumbnail,
    duration,
    Object.hashAll(artists),
    album,
    videoType,
    isExplicit,
  );
}
