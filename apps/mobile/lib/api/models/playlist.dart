import "package:hive/hive.dart";

part "playlist.g.dart";

@HiveType(typeId: 1)
class Playlist {
  @HiveField(0)
  final String playlistId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String authorGoogleEmail;
  @HiveField(3)
  final String authorName;
  @HiveField(4)
  final String authorImage;
  @HiveField(5)
  final String? coverImage;
  @HiveField(6)
  final bool isPublic;

  const Playlist({
    required this.playlistId,
    required this.name,
    required this.authorGoogleEmail,
    required this.authorImage,
    required this.authorName,
    required this.coverImage,
    required this.isPublic,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json["playlistId"] as String,
      name: json["name"] as String,
      authorGoogleEmail: json["authorGoogleEmail"] as String,
      authorName: json["authorName"] as String,
      authorImage: json["authorImage"] as String,
      coverImage: json["coverImage"] as String?,
      isPublic: json["isPublic"] as bool,
    );
  }

  @override
  String toString() =>
      "Playlist(playlistId: $playlistId, name: $name, authorGoogleEmail: $authorGoogleEmail, authorImage: $authorImage, $authorName: authorName, coverImage: $coverImage, isPublic: $isPublic)";
}
