import "package:hive_flutter/adapters.dart";

part "lyric.g.dart";

@HiveType(typeId: 2)
class Lyric {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final int startMs;
  @HiveField(2)
  final int durMs;

  const Lyric({required this.text, required this.startMs, required this.durMs});

  factory Lyric.fromJson(Map<String, dynamic> json) {
    return Lyric(
      text: json["text"] as String,
      startMs: json["startMs"] as int,
      durMs: json["durMs"] as int,
    );
  }
}
