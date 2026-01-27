import "package:flutter/foundation.dart";

@immutable
class Video {
  final String videoId;
  final String title;
  final String thumbnail;
  final String author;
  final String authorChannelId;

  const Video({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.author,
    required this.authorChannelId,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
      authorChannelId: json["authorChannelId"] as String,
    );
  }

  @override
  String toString() =>
      "Video(videoId: $videoId, title: $title, thumbnail: $thumbnail, author: $author, authorChannelId: $authorChannelId)";
}
