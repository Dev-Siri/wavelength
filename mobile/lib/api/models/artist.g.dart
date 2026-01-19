// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtistTopSongTrackAdapter extends TypeAdapter<ArtistTopSongTrack> {
  @override
  final int typeId = 11;

  @override
  ArtistTopSongTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtistTopSongTrack(
      videoId: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      playCount: fields[3] as String,
      isExplicit: fields[4] as bool,
      album: fields[5] as EmbeddedAlbum?,
    );
  }

  @override
  void write(BinaryWriter writer, ArtistTopSongTrack obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.playCount)
      ..writeByte(4)
      ..write(obj.isExplicit)
      ..writeByte(5)
      ..write(obj.album);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistTopSongTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArtistAlbumAdapter extends TypeAdapter<ArtistAlbum> {
  @override
  final int typeId = 10;

  @override
  ArtistAlbum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtistAlbum(
      albumId: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      releaseDate: fields[3] as String,
      albumType: fields[4] as AlbumType,
    );
  }

  @override
  void write(BinaryWriter writer, ArtistAlbum obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.albumId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.releaseDate)
      ..writeByte(4)
      ..write(obj.albumType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistAlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArtistAdapter extends TypeAdapter<Artist> {
  @override
  final int typeId = 9;

  @override
  Artist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artist(
      browseId: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      description: fields[3] as String,
      audience: fields[4] as String,
      topSongs: (fields[5] as List).cast<ArtistTopSongTrack>(),
      albums: (fields[6] as List).cast<ArtistAlbum>(),
      singlesAndEps: (fields[7] as List).cast<ArtistAlbum>(),
    );
  }

  @override
  void write(BinaryWriter writer, Artist obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.browseId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.audience)
      ..writeByte(5)
      ..write(obj.topSongs)
      ..writeByte(6)
      ..write(obj.albums)
      ..writeByte(7)
      ..write(obj.singlesAndEps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FollowedArtistAdapter extends TypeAdapter<FollowedArtist> {
  @override
  final int typeId = 8;

  @override
  FollowedArtist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FollowedArtist(
      followId: fields[0] as String,
      browseId: fields[1] as String,
      followerEmail: fields[2] as String,
      name: fields[3] as String,
      thumbnail: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FollowedArtist obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.followId)
      ..writeByte(1)
      ..write(obj.browseId)
      ..writeByte(2)
      ..write(obj.followerEmail)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.thumbnail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowedArtistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
