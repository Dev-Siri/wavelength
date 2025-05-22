class Track {
  final String videoId;
  final String title;
  final String thumbnail;
  final String author;
  final String duration;
  final bool isExplicit;

  const Track({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.author,
    required this.duration,
    required this.isExplicit,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
      duration: json["duration"] as String,
      isExplicit: json["isExplicit"] as bool,
    );
  }
}
