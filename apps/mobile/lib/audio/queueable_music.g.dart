// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queueable_music.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueableMusicAdapter extends TypeAdapter<QueueableMusic> {
  @override
  final int typeId = 25;

  @override
  QueueableMusic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueueableMusic(
      videoId: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      duration: fields[3] as int,
      artists: (fields[4] as List).cast<EmbeddedArtist>(),
      album: fields[5] as EmbeddedAlbum?,
      videoType: fields[6] as VideoType,
      isExplicit: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QueueableMusic obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.artists)
      ..writeByte(5)
      ..write(obj.album)
      ..writeByte(6)
      ..write(obj.videoType)
      ..writeByte(7)
      ..write(obj.isExplicit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueableMusicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
