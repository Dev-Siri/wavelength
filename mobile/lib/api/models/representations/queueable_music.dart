import "package:wavelength/api/models/playlist_track.dart";

class QueueableMusic {
  final String videoId;
  final String title;
  final String thumbnail;
  final Duration duration;
  final String author;
  final VideoType videoType;

  const QueueableMusic({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.author,
    required this.videoType,
  });
}
