import "package:flutter/foundation.dart";
import "package:hive/hive.dart";

part "embedded.g.dart";

@immutable
@HiveType(typeId: 4)
class EmbeddedArtist {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String browseId;

  const EmbeddedArtist({required this.title, required this.browseId});

  factory EmbeddedArtist.fromJson(Map<String, dynamic> json) {
    return EmbeddedArtist(
      title: json["title"] as String,
      browseId: json["browseId"] as String,
    );
  }

  Map<String, String> toJson() {
    return {"title": title, "browseId": browseId};
  }

  @override
  String toString() => "EmbeddedArtist(title: $title, browseId: $browseId)";
}

@immutable
@HiveType(typeId: 5)
class EmbeddedAlbum {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String browseId;

  const EmbeddedAlbum({required this.title, required this.browseId});

  factory EmbeddedAlbum.fromJson(Map<String, dynamic> json) {
    return EmbeddedAlbum(
      title: json["title"] as String,
      browseId: json["browseId"] as String,
    );
  }

  Map<String, String> toJson() {
    return {"title": title, "browseId": browseId};
  }

  @override
  String toString() => "EmbeddedAlbum(title: $title, browseId: $browseId)";
}
