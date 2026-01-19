import "package:hive/hive.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";

part "playlist_track.g.dart";

@HiveType(typeId: 0)
class PlaylistTrack {
  @HiveField(0)
  final String playlistTrackId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnail;
  @HiveField(3)
  final int positionInPlaylist;
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
  final String playlistId;

  PlaylistTrack({
    required this.playlistTrackId,
    required this.title,
    required this.thumbnail,
    required this.positionInPlaylist,
    required this.isExplicit,
    required this.artists,
    required this.duration,
    required this.videoId,
    required this.videoType,
    required this.playlistId,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistTrack(
      playlistTrackId: json["playlistTrackId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      positionInPlaylist: json["positionInPlaylist"] as int,
      isExplicit: json["isExplicit"] as bool,
      artists: (json["artists"] as List)
          .map((artist) => EmbeddedArtist.fromJson(artist))
          .toList(),
      duration: int.parse(json["duration"]),
      videoId: json["videoId"] as String,
      videoType: VideoTypeParser.fromGrpc(json["videoType"]),
      playlistId: json["playlistId"] as String,
    );
  }
}
