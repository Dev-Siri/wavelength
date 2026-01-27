// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyric.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LyricAdapter extends TypeAdapter<Lyric> {
  @override
  final int typeId = 2;

  @override
  Lyric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lyric(
      text: fields[0] as String,
      startMs: fields[1] as int,
      durMs: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Lyric obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.startMs)
      ..writeByte(2)
      ..write(obj.durMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
