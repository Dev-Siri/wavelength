class PlaylistTracksLength {
  final int songCount;
  final int songDurationSecond;

  const PlaylistTracksLength({
    required this.songCount,
    required this.songDurationSecond,
  });

  factory PlaylistTracksLength.fromJson(Map<String, dynamic> json) {
    return PlaylistTracksLength(
      songCount: json["songCount"] as int,
      songDurationSecond: json["songDurationSecond"] as int,
    );
  }
}
