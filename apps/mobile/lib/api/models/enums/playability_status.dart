import "package:hive_flutter/hive_flutter.dart";

part "playability_status.g.dart";

@HiveType(typeId: 18)
enum PlayabilityStatus {
  @HiveField(0)
  unplayable,
  @HiveField(1)
  playable,
  @HiveField(2)
  unavailable,
}

extension PlayabilityStatusParser on PlayabilityStatus {
  static PlayabilityStatus fromEnumString(String value) {
    switch (value) {
      case "UNPLAYABLE":
        return PlayabilityStatus.unplayable;
      case "PLAYABLE":
        return PlayabilityStatus.playable;
      case "UNAVAILABLE":
        return PlayabilityStatus.unavailable;
    }
    return PlayabilityStatus.unplayable;
  }

  String toEnumString() {
    switch (this) {
      case PlayabilityStatus.unplayable:
        return "UNPLAYABLE";
      case PlayabilityStatus.playable:
        return "PLAYABLE";
      case PlayabilityStatus.unavailable:
        return "UNAVAILABLE";
    }
  }
}
