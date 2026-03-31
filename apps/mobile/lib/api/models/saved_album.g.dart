// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_album.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedAlbumAdapter extends TypeAdapter<SavedAlbum> {
  @override
  final int typeId = 26;

  @override
  SavedAlbum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedAlbum(
      saverEmail: fields[0] as String,
      albumId: fields[1] as String,
      title: fields[2] as String,
      albumCover: fields[3] as String,
      albumSongCount: fields[4] as int,
      albumDuration: fields[5] as String,
      albumAuthor: fields[6] as String,
      albumType: fields[7] as AlbumType,
    );
  }

  @override
  void write(BinaryWriter writer, SavedAlbum obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.saverEmail)
      ..writeByte(1)
      ..write(obj.albumId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.albumCover)
      ..writeByte(4)
      ..write(obj.albumSongCount)
      ..writeByte(5)
      ..write(obj.albumDuration)
      ..writeByte(6)
      ..write(obj.albumAuthor)
      ..writeByte(7)
      ..write(obj.albumType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
