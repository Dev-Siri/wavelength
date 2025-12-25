import "package:wavelength/api/models/playlist_track.dart";

class LikedTrack {
  final String likeId;
  final String email;
  final String title;
  final String thumbnail;
  final bool isExplicit;
  final String author;
  final String duration;
  final String videoId;
  final VideoType videoType;

  LikedTrack({
    required this.likeId,
    required this.email,
    required this.title,
    required this.thumbnail,
    required this.isExplicit,
    required this.author,
    required this.duration,
    required this.videoId,
    required this.videoType,
  });

  factory LikedTrack.fromJson(Map<String, dynamic> json) {
    return LikedTrack(
      likeId: json["likeId"] as String,
      email: json["email"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      isExplicit: json["isExplicit"] as bool,
      author: json["author"] as String,
      duration: json["duration"] as String,
      videoId: json["videoId"] as String,
      videoType: json["videoType"] == "track"
          ? VideoType.track
          : VideoType.uvideo,
    );
  }
}
