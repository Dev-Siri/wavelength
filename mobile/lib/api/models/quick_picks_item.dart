import "package:flutter/foundation.dart";
import "package:wavelength/api/models/embedded.dart";

@immutable
class QuickPicksItem {
  final String videoId;
  final String title;
  final String thumbnail;
  final List<EmbeddedArtist> artists;
  final EmbeddedAlbum? album;

  const QuickPicksItem({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.artists,
    required this.album,
  });

  factory QuickPicksItem.fromJson(Map<String, dynamic> json) {
    return QuickPicksItem(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      artists: (json["artists"] as List)
          .map((artist) => EmbeddedArtist.fromJson(artist))
          .toList(),
      album: json["album"] != null
          ? EmbeddedAlbum.fromJson(json["album"])
          : null,
    );
  }
}
