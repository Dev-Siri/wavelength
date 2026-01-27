// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumTypeAdapter extends TypeAdapter<AlbumType> {
  @override
  final int typeId = 14;

  @override
  AlbumType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlbumType.unspecified;
      case 1:
        return AlbumType.album;
      case 2:
        return AlbumType.single;
      case 3:
        return AlbumType.ep;
      default:
        return AlbumType.unspecified;
    }
  }

  @override
  void write(BinaryWriter writer, AlbumType obj) {
    switch (obj) {
      case AlbumType.unspecified:
        writer.writeByte(0);
        break;
      case AlbumType.album:
        writer.writeByte(1);
        break;
      case AlbumType.single:
        writer.writeByte(2);
        break;
      case AlbumType.ep:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
