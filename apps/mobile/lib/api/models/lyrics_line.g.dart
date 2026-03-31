// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_line.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyllableAdapter extends TypeAdapter<Syllable> {
  @override
  final int typeId = 23;

  @override
  Syllable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Syllable(
      text: fields[0] as String,
      part: fields[1] as bool?,
      timestamp: fields[2] as int,
      endtime: fields[3] as int,
      romanizedText: fields[4] as String?,
      lineSynced: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Syllable obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.part)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.endtime)
      ..writeByte(4)
      ..write(obj.romanizedText)
      ..writeByte(5)
      ..write(obj.lineSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LyricsLineAdapter extends TypeAdapter<LyricsLine> {
  @override
  final int typeId = 21;

  @override
  LyricsLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LyricsLine(
      text: (fields[0] as List?)?.cast<Syllable>(),
      background: fields[1] as bool?,
      backgroundText: (fields[2] as List?)?.cast<Syllable>(),
      oppositeTurn: fields[3] as bool?,
      timestamp: fields[4] as int,
      endtime: fields[5] as int,
      isWordSynced: fields[6] as bool?,
      alignment: fields[7] as AlignmentDirection?,
      songPart: fields[8] as String?,
      romanizedText: fields[9] as String?,
      translation: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LyricsLine obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.background)
      ..writeByte(2)
      ..write(obj.backgroundText)
      ..writeByte(3)
      ..write(obj.oppositeTurn)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.endtime)
      ..writeByte(6)
      ..write(obj.isWordSynced)
      ..writeByte(7)
      ..write(obj.alignment)
      ..writeByte(8)
      ..write(obj.songPart)
      ..writeByte(9)
      ..write(obj.romanizedText)
      ..writeByte(10)
      ..write(obj.translation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricsLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LyricsAdapter extends TypeAdapter<Lyrics> {
  @override
  final int typeId = 22;

  @override
  Lyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lyrics(
      source: fields[0] as String,
      lines: (fields[1] as List).cast<LyricsLine>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lyrics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.source)
      ..writeByte(1)
      ..write(obj.lines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
