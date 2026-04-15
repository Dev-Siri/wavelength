// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HlsStreamMetadataAdapter extends TypeAdapter<HlsStreamMetadata> {
  @override
  final int typeId = 20;

  @override
  HlsStreamMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HlsStreamMetadata(
      streamId: fields[0] as String,
      bitrate: fields[1] as double,
      codec: fields[2] as String,
      container: fields[3] as String,
      durationSeconds: fields[4] as double,
      isHifiAvailable: fields[5] as bool,
      isLosslessAvailable: fields[6] as LosslessAvailability?,
      sampleRate: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HlsStreamMetadata obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.streamId)
      ..writeByte(1)
      ..write(obj.bitrate)
      ..writeByte(2)
      ..write(obj.codec)
      ..writeByte(3)
      ..write(obj.container)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.isHifiAvailable)
      ..writeByte(6)
      ..write(obj.isLosslessAvailable)
      ..writeByte(7)
      ..write(obj.sampleRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HlsStreamMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HlsStreamSourceAdapter extends TypeAdapter<HlsStreamSource> {
  @override
  final int typeId = 19;

  @override
  HlsStreamSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HlsStreamSource(
      metadata: fields[0] as HlsStreamMetadata,
      source: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HlsStreamSource obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.metadata)
      ..writeByte(1)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HlsStreamSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
