import "package:flutter/foundation.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/album_type.dart";

part "artist.g.dart";

@immutable
class SearchArtist {
  final String browseId;
  final String title;
  final String thumbnail;
  final String audience;

  const SearchArtist({
    required this.browseId,
    required this.title,
    required this.thumbnail,
    required this.audience,
  });

  factory SearchArtist.fromJson(Map<String, dynamic> json) {
    return SearchArtist(
      browseId: json["browseId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      audience: json["audience"] as String,
    );
  }

  @override
  String toString() =>
      "SearchArtist(browseId: $browseId, title: $title, thumbnail: $thumbnail, audience: $audience)";
}

@immutable
@HiveType(typeId: 11)
class ArtistTopSongTrack {
  @HiveField(0)
  final String videoId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnail;
  @HiveField(3)
  final String playCount;
  @HiveField(4)
  final bool isExplicit;
  @HiveField(5)
  final EmbeddedAlbum? album;

  const ArtistTopSongTrack({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.playCount,
    required this.isExplicit,
    required this.album,
  });

  factory ArtistTopSongTrack.fromJson(Map<String, dynamic> json) {
    return ArtistTopSongTrack(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      playCount: json["playCount"] as String,
      isExplicit: json["isExplicit"] as bool,
      album: json["album"] != null
          ? EmbeddedAlbum.fromJson(json["album"])
          : null,
    );
  }

  @override
  String toString() =>
      "ArtistTopSongTrack(videoId: $videoId, title: $title, thumbnail: $thumbnail, playCount: $playCount, isExplicit: $isExplicit, album: $album)";
}

@immutable
@HiveType(typeId: 10)
class ArtistAlbum {
  @HiveField(0)
  final String albumId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnail;
  @HiveField(3)
  final String releaseDate;
  @HiveField(4)
  final AlbumType albumType;

  const ArtistAlbum({
    required this.albumId,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
    required this.albumType,
  });

  factory ArtistAlbum.fromJson(Map<String, dynamic> json) {
    return ArtistAlbum(
      albumId: json["albumId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      releaseDate: json["releaseDate"] as String,
      albumType: AlbumTypeParser.fromGrpc(json["albumType"]),
    );
  }

  @override
  String toString() =>
      "ArtistAlbum(albumId: $albumId, title: $title, thumbnail: $thumbnail, releaseDate: $releaseDate, albumType: $albumType)";
}

@immutable
@HiveType(typeId: 9)
class Artist {
  @HiveField(0)
  final String browseId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnail;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String audience;
  @HiveField(5)
  final List<ArtistTopSongTrack> topSongs;
  @HiveField(6)
  final List<ArtistAlbum> albums;
  @HiveField(7)
  final List<ArtistAlbum> singlesAndEps;

  const Artist({
    required this.browseId,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.audience,
    required this.topSongs,
    required this.albums,
    required this.singlesAndEps,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      browseId: json["browseId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      description: json["description"] as String,
      audience: json["audience"] as String,
      topSongs: (json["topSongs"] as List)
          .map((final song) => ArtistTopSongTrack.fromJson(song))
          .toList(),
      albums: (json["albums"] as List)
          .map((final album) => ArtistAlbum.fromJson(album))
          .toList(),
      singlesAndEps: (json["singlesAndEps"] as List)
          .map((final album) => ArtistAlbum.fromJson(album))
          .toList(),
    );
  }
}

@immutable
@HiveType(typeId: 8)
class FollowedArtist {
  @HiveField(0)
  final String followId;
  @HiveField(1)
  final String browseId;
  @HiveField(2)
  final String followerEmail;
  @HiveField(3)
  final String name;
  @HiveField(4)
  final String thumbnail;

  const FollowedArtist({
    required this.followId,
    required this.browseId,
    required this.followerEmail,
    required this.name,
    required this.thumbnail,
  });

  factory FollowedArtist.fromJson(Map<String, dynamic> json) {
    return FollowedArtist(
      browseId: json["browseId"] as String,
      followId: json["followId"] as String,
      followerEmail: json["followerEmail"] as String,
      name: json["name"] as String,
      thumbnail: json["thumbnail"] as String,
    );
  }

  @override
  String toString() =>
      "FollowedArtist(followId: $followId, browseId: $browseId, followerEmail: $followerEmail, name: $name, thumbnail: $thumbnail)";
}
