// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alignment_direction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlignmentDirectionAdapter extends TypeAdapter<AlignmentDirection> {
  @override
  final int typeId = 24;

  @override
  AlignmentDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlignmentDirection.unspecified;
      case 1:
        return AlignmentDirection.start;
      case 2:
        return AlignmentDirection.end;
      default:
        return AlignmentDirection.unspecified;
    }
  }

  @override
  void write(BinaryWriter writer, AlignmentDirection obj) {
    switch (obj) {
      case AlignmentDirection.unspecified:
        writer.writeByte(0);
        break;
      case AlignmentDirection.start:
        writer.writeByte(1);
        break;
      case AlignmentDirection.end:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlignmentDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
