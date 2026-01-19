import "package:flutter/foundation.dart";

@immutable
class VersionStatus {
  final String latestVersion;

  const VersionStatus({required this.latestVersion});

  factory VersionStatus.fromJson(Map<String, dynamic> json) {
    return VersionStatus(latestVersion: json["latestVersion"] as String);
  }
}
