// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoTypeAdapter extends TypeAdapter<VideoType> {
  @override
  final int typeId = 15;

  @override
  VideoType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VideoType.unspecified;
      case 1:
        return VideoType.track;
      case 2:
        return VideoType.uvideo;
      default:
        return VideoType.unspecified;
    }
  }

  @override
  void write(BinaryWriter writer, VideoType obj) {
    switch (obj) {
      case VideoType.unspecified:
        writer.writeByte(0);
        break;
      case VideoType.track:
        writer.writeByte(1);
        break;
      case VideoType.uvideo:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
