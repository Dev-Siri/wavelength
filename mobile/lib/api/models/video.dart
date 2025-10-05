class Video {
  final String videoId;
  final String title;
  final String thumbnail;
  final String author;

  const Video({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.author,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
    );
  }
}
