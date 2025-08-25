class ThemeColor {
  final int r;
  final int g;
  final int b;

  const ThemeColor({required this.r, required this.g, required this.b});

  factory ThemeColor.fromJson(Map<String, dynamic> json) {
    return ThemeColor(
      r: json["r"] as int,
      g: json["g"] as int,
      b: json["b"] as int,
    );
  }
}
