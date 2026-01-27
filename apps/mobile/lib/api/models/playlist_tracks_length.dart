import "package:hive/hive.dart";

part "playlist_tracks_length.g.dart";

@HiveType(typeId: 6)
class PlaylistTracksLength {
  @HiveField(0)
  final int songCount;
  @HiveField(1)
  final int songDurationSecond;

  const PlaylistTracksLength({
    required this.songCount,
    required this.songDurationSecond,
  });

  factory PlaylistTracksLength.fromJson(Map<String, dynamic> json) {
    return PlaylistTracksLength(
      songCount: int.parse(json["songCount"]),
      songDurationSecond: int.parse(json["songDurationSecond"]),
    );
  }
}
