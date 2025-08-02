enum VideoType { track, uvideo }

class PlaylistTrack {
  final String playlistTrackId;
  final String title;
  final String thumbnail;
  final int positionInPlaylist;
  final bool isExplicit;
  final String author;
  final String duration;
  final String videoId;
  final VideoType videoType;
  final String playlistId;

  PlaylistTrack({
    required this.playlistTrackId,
    required this.title,
    required this.thumbnail,
    required this.positionInPlaylist,
    required this.isExplicit,
    required this.author,
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
      author: json["author"] as String,
      duration: json["duration"] as String,
      videoId: json["videoId"] as String,
      videoType:
          json["videoType"] == "track" ? VideoType.track : VideoType.uvideo,
      playlistId: json["playlistId"] as String,
    );
  }
}
