import "package:hive_flutter/adapters.dart";

part "alignment_direction.g.dart";

@HiveType(typeId: 24)
enum AlignmentDirection {
  @HiveField(0)
  unspecified,
  @HiveField(1)
  start,
  @HiveField(2)
  end,
}
