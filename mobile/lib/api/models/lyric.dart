class Lyric {
  final String text;
  final int startMs;
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
