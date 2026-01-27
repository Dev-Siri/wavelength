import "package:flutter/foundation.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/album_type.dart";

part "album.g.dart";

@immutable
class SearchAlbum {
  final String albumId;
  final String title;
  final String thumbnail;
  final String releaseDate;
  final AlbumType albumType;
  final EmbeddedArtist artist;

  const SearchAlbum({
    required this.albumId,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
    required this.albumType,
    required this.artist,
  });

  factory SearchAlbum.fromJson(Map<String, dynamic> json) {
    return SearchAlbum(
      albumId: json["albumId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      releaseDate: json["releaseDate"] as String,
      albumType: AlbumTypeParser.fromGrpc(json["albumType"]),
      artist: EmbeddedArtist.fromJson(json["artist"]),
    );
  }

  @override
  String toString() =>
      "SearchAlbum(albumId: $albumId, title: $title, thumbnail: $thumbnail, releaseDate: $releaseDate, albumType: $albumType, artist: $artist)";
}

@immutable
@HiveType(typeId: 13)
class AlbumTrack {
  @HiveField(0)
  final String videoId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final int duration;
  @HiveField(3)
  final int positionInAlbum;
  @HiveField(4)
  final bool isExplicit;

  const AlbumTrack({
    required this.videoId,
    required this.title,
    required this.duration,
    required this.positionInAlbum,
    required this.isExplicit,
  });

  factory AlbumTrack.fromJson(Map<String, dynamic> json) {
    return AlbumTrack(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      duration: int.parse(json["duration"]),
      positionInAlbum: json["positionInAlbum"] as int,
      isExplicit: json["isExplicit"] as bool,
    );
  }

  @override
  String toString() =>
      "AlbumTrack(videoId: $videoId, title: $title, duration: $duration, positionInAlbum: $positionInAlbum, isExplicit: $isExplicit)";
}

@immutable
@HiveType(typeId: 12)
class Album {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final AlbumType albumType;
  @HiveField(2)
  final String release;
  @HiveField(3)
  final String cover;
  @HiveField(4)
  final int totalSongCount;
  @HiveField(5)
  final String totalDuration;
  @HiveField(6)
  final EmbeddedArtist artist;
  @HiveField(7)
  final List<AlbumTrack> albumTracks;

  const Album({
    required this.release,
    required this.albumType,
    required this.title,
    required this.cover,
    required this.totalSongCount,
    required this.totalDuration,
    required this.artist,
    required this.albumTracks,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      title: json["title"] as String,
      albumType: AlbumTypeParser.fromGrpc(json["albumType"]),
      release: json["release"] as String,
      cover: json["cover"] as String,
      totalSongCount: json["totalSongCount"] as int,
      totalDuration: json["totalDuration"] as String,
      artist: EmbeddedArtist.fromJson(json["artist"]),
      albumTracks: (json["albumTracks"] as List)
          .map((track) => AlbumTrack.fromJson(track))
          .toList(),
    );
  }

  @override
  String toString() =>
      "Album(release: $release, albumType: $albumType, title: $title, cover: $cover, totalSongCount: $totalSongCount, totalDuration: $totalDuration, artist: $artist)";
}
