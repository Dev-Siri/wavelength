import "package:hive_flutter/adapters.dart";

part "lossless_availability.g.dart";

@HiveType(typeId: 27)
enum LosslessAvailability {
  @HiveField(0)
  bit24,
  @HiveField(1)
  bit16,
}
