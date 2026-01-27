class MusicVideoPreview {
  final String videoId;

  const MusicVideoPreview({required this.videoId});

  factory MusicVideoPreview.fromJson(Map<String, dynamic> json) {
    return MusicVideoPreview(videoId: json["videoId"] as String);
  }
}
