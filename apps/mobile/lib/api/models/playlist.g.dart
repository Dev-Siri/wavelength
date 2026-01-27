// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      playlistId: fields[0] as String,
      name: fields[1] as String,
      authorGoogleEmail: fields[2] as String,
      authorImage: fields[4] as String,
      authorName: fields[3] as String,
      coverImage: fields[5] as String?,
      isPublic: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.playlistId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.authorGoogleEmail)
      ..writeByte(3)
      ..write(obj.authorName)
      ..writeByte(4)
      ..write(obj.authorImage)
      ..writeByte(5)
      ..write(obj.coverImage)
      ..writeByte(6)
      ..write(obj.isPublic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
