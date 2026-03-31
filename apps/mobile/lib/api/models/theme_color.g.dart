// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_color.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeColorAdapter extends TypeAdapter<ThemeColor> {
  @override
  final int typeId = 17;

  @override
  ThemeColor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeColor(
      r: fields[0] as int,
      g: fields[1] as int,
      b: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeColor obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.r)
      ..writeByte(1)
      ..write(obj.g)
      ..writeByte(2)
      ..write(obj.b);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
