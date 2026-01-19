// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumTrackAdapter extends TypeAdapter<AlbumTrack> {
  @override
  final int typeId = 13;

  @override
  AlbumTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlbumTrack(
      videoId: fields[0] as String,
      title: fields[1] as String,
      duration: fields[2] as int,
      positionInAlbum: fields[3] as int,
      isExplicit: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AlbumTrack obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.positionInAlbum)
      ..writeByte(4)
      ..write(obj.isExplicit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlbumAdapter extends TypeAdapter<Album> {
  @override
  final int typeId = 12;

  @override
  Album read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Album(
      release: fields[2] as String,
      albumType: fields[1] as AlbumType,
      title: fields[0] as String,
      cover: fields[3] as String,
      totalSongCount: fields[4] as int,
      totalDuration: fields[5] as String,
      artist: fields[6] as EmbeddedArtist,
      albumTracks: (fields[7] as List).cast<AlbumTrack>(),
    );
  }

  @override
  void write(BinaryWriter writer, Album obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.albumType)
      ..writeByte(2)
      ..write(obj.release)
      ..writeByte(3)
      ..write(obj.cover)
      ..writeByte(4)
      ..write(obj.totalSongCount)
      ..writeByte(5)
      ..write(obj.totalDuration)
      ..writeByte(6)
      ..write(obj.artist)
      ..writeByte(7)
      ..write(obj.albumTracks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
