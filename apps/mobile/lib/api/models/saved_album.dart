import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/enums/album_type.dart";

part "saved_album.g.dart";

@HiveType(typeId: 26)
class SavedAlbum {
  @HiveField(0)
  final String saverEmail;
  @HiveField(1)
  final String albumId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String albumCover;
  @HiveField(4)
  final int albumSongCount;
  @HiveField(5)
  final String albumDuration;
  @HiveField(6)
  final String albumAuthor;
  @HiveField(7)
  final AlbumType albumType;

  const SavedAlbum({
    required this.saverEmail,
    required this.albumId,
    required this.title,
    required this.albumCover,
    required this.albumSongCount,
    required this.albumDuration,
    required this.albumAuthor,
    required this.albumType,
  });

  factory SavedAlbum.fromJson(Map<String, dynamic> json) {
    return SavedAlbum(
      saverEmail: json["saverEmail"] as String,
      albumId: json["albumId"] as String,
      title: json["title"] as String,
      albumCover: json["albumCover"] as String,
      albumSongCount: json["albumSongCount"] as int,
      albumDuration: json["albumDuration"] as String,
      albumAuthor: json["albumAuthor"] as String,
      albumType: AlbumTypeParser.fromGrpc(json["albumType"] as String),
    );
  }
}
