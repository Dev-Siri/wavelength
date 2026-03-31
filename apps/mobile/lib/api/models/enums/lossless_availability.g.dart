// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lossless_availability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LosslessAvailabilityAdapter extends TypeAdapter<LosslessAvailability> {
  @override
  final int typeId = 27;

  @override
  LosslessAvailability read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LosslessAvailability.bit24;
      case 1:
        return LosslessAvailability.bit16;
      default:
        return LosslessAvailability.bit24;
    }
  }

  @override
  void write(BinaryWriter writer, LosslessAvailability obj) {
    switch (obj) {
      case LosslessAvailability.bit24:
        writer.writeByte(0);
        break;
      case LosslessAvailability.bit16:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LosslessAvailabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
