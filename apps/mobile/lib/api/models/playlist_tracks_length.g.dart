// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_tracks_length.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistTracksLengthAdapter extends TypeAdapter<PlaylistTracksLength> {
  @override
  final int typeId = 6;

  @override
  PlaylistTracksLength read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistTracksLength(
      songCount: fields[0] as int,
      songDurationSecond: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistTracksLength obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.songCount)
      ..writeByte(1)
      ..write(obj.songDurationSecond);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistTracksLengthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
