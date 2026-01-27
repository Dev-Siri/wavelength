// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikedTrackAdapter extends TypeAdapter<LikedTrack> {
  @override
  final int typeId = 3;

  @override
  LikedTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LikedTrack(
      likeId: fields[0] as String,
      email: fields[1] as String,
      title: fields[2] as String,
      thumbnail: fields[3] as String,
      isExplicit: fields[4] as bool,
      artists: (fields[5] as List).cast<EmbeddedArtist>(),
      duration: fields[6] as int,
      videoId: fields[7] as String,
      videoType: fields[8] as VideoType,
    );
  }

  @override
  void write(BinaryWriter writer, LikedTrack obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.likeId)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.thumbnail)
      ..writeByte(4)
      ..write(obj.isExplicit)
      ..writeByte(5)
      ..write(obj.artists)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.videoId)
      ..writeByte(8)
      ..write(obj.videoType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikedTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
