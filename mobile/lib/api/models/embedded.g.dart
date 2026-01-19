// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedded.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmbeddedArtistAdapter extends TypeAdapter<EmbeddedArtist> {
  @override
  final int typeId = 4;

  @override
  EmbeddedArtist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmbeddedArtist(
      title: fields[0] as String,
      browseId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmbeddedArtist obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.browseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddedArtistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmbeddedAlbumAdapter extends TypeAdapter<EmbeddedAlbum> {
  @override
  final int typeId = 5;

  @override
  EmbeddedAlbum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmbeddedAlbum(
      title: fields[0] as String,
      browseId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmbeddedAlbum obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.browseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddedAlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
