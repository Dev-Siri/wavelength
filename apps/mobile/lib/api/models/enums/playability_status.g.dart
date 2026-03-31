// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playability_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayabilityStatusAdapter extends TypeAdapter<PlayabilityStatus> {
  @override
  final int typeId = 18;

  @override
  PlayabilityStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlayabilityStatus.unplayable;
      case 1:
        return PlayabilityStatus.playable;
      case 2:
        return PlayabilityStatus.unavailable;
      default:
        return PlayabilityStatus.unplayable;
    }
  }

  @override
  void write(BinaryWriter writer, PlayabilityStatus obj) {
    switch (obj) {
      case PlayabilityStatus.unplayable:
        writer.writeByte(0);
        break;
      case PlayabilityStatus.playable:
        writer.writeByte(1);
        break;
      case PlayabilityStatus.unavailable:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayabilityStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
