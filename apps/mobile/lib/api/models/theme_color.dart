import "package:hive/hive.dart";

part "theme_color.g.dart";

@HiveType(typeId: 17)
class ThemeColor {
  @HiveField(0)
  final int r;
  @HiveField(1)
  final int g;
  @HiveField(2)
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
