// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 7;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      videoId: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      artists: (fields[3] as List).cast<EmbeddedArtist>(),
      duration: fields[4] as int,
      isExplicit: fields[5] as bool,
      album: fields[6] as EmbeddedAlbum?,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.artists)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.isExplicit)
      ..writeByte(6)
      ..write(obj.album);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
