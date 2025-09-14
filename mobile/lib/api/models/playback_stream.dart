class PlaybackStream {
  final String url;
  final String ext;
  final double abr;
  final int duration;

  PlaybackStream({
    required this.url,
    required this.ext,
    required this.abr,
    required this.duration,
  });

  factory PlaybackStream.fromJson(Map<String, dynamic> json) {
    return PlaybackStream(
      url: json["url"] as String,
      ext: json["ext"] as String,
      abr: json["abr"] as double,
      duration: json["duration"] as int,
    );
  }
}
