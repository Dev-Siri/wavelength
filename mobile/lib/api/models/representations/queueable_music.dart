import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";

class QueueableMusic {
  final String videoId;
  final String title;
  final String thumbnail;
  final List<EmbeddedArtist> artists;
  final EmbeddedAlbum? album;
  final VideoType videoType;

  const QueueableMusic({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.artists,
    required this.album,
    required this.videoType,
  });
}
