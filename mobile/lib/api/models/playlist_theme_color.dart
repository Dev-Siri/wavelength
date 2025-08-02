class PlaylistThemeColor {
  final int r;
  final int g;
  final int b;

  const PlaylistThemeColor({required this.r, required this.g, required this.b});

  factory PlaylistThemeColor.fromJson(Map<String, dynamic> json) {
    return PlaylistThemeColor(
      r: json["r"] as int,
      g: json["g"] as int,
      b: json["b"] as int,
    );
  }
}
