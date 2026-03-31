import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/enums/alignment_direction.dart";

part "lyrics_line.g.dart";

@HiveType(typeId: 23)
class Syllable {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final bool? part;
  @HiveField(2)
  final int timestamp;
  @HiveField(3)
  final int endtime;
  @HiveField(4)
  final String? romanizedText;
  @HiveField(5)
  final bool? lineSynced;

  const Syllable({
    required this.text,
    this.part,
    required this.timestamp,
    required this.endtime,
    this.romanizedText,
    this.lineSynced,
  });

  factory Syllable.fromJson(Map<String, dynamic> json) {
    return Syllable(
      text: json["text"] as String,
      part: json["part"] as bool?,
      timestamp: int.parse(json["timestamp"] as String),
      endtime: int.parse(json["endtime"] as String),
      romanizedText: json["romanizedText"] as String?,
      lineSynced: json["lineSynced"] as bool?,
    );
  }
}

@HiveType(typeId: 21)
class LyricsLine {
  @HiveField(0)
  final List<Syllable>? text;
  @HiveField(1)
  final bool? background;
  @HiveField(2)
  final List<Syllable>? backgroundText;
  @HiveField(3)
  final bool? oppositeTurn;
  @HiveField(4)
  final int timestamp;
  @HiveField(5)
  final int endtime;
  @HiveField(6)
  final bool? isWordSynced;
  @HiveField(7)
  final AlignmentDirection? alignment;
  @HiveField(8)
  final String? songPart;
  @HiveField(9)
  final String? romanizedText;
  @HiveField(10)
  final String? translation;

  const LyricsLine({
    this.text,
    this.background,
    this.backgroundText,
    this.oppositeTurn,
    required this.timestamp,
    required this.endtime,
    this.isWordSynced,
    this.alignment,
    this.songPart,
    this.romanizedText,
    this.translation,
  });

  factory LyricsLine.fromJson(Map<String, dynamic> json) {
    return LyricsLine(
      text: (json["text"] as List?)?.map((e) => Syllable.fromJson(e)).toList(),
      background: json["background"] as bool?,
      backgroundText: (json["backgroundText"] as List?)
          ?.map((e) => Syllable.fromJson(e))
          .toList(),
      oppositeTurn: json["oppositeTurn"] as bool?,
      timestamp: int.parse((json["timestamp"] as String)),
      endtime: int.parse((json["endtime"] as String)),
      isWordSynced: json["isWordSynced"] as bool?,
      alignment: json["alignment"] != null
          ? (() {
              final value = json["alignment"] as String;
              switch (value) {
                case "ALIGNMENT_DIRECTION_START":
                  return AlignmentDirection.start;
                case "ALIGNMENT_DIRECTION_END":
                  return AlignmentDirection.end;
                default:
                  return null;
              }
            })()
          : null,
      songPart: json["songPart"] as String?,
      romanizedText: json["romanizedText"] as String?,
      translation: json["translation"] as String?,
    );
  }
}

@HiveType(typeId: 22)
class Lyrics {
  @HiveField(0)
  final String source;
  @HiveField(1)
  final List<LyricsLine> lines;

  const Lyrics({required this.source, required this.lines});

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      source: json["source"] as String,
      lines:
          (json["lines"] as List?)
              ?.map((line) => LyricsLine.fromJson(line))
              .toList() ??
          [],
    );
  }
}
