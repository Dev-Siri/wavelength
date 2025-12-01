class VersionStatus {
  final String latestVersion;

  VersionStatus({required this.latestVersion});

  factory VersionStatus.fromJson(Map<String, dynamic> json) {
    return VersionStatus(latestVersion: json["latestVersion"] as String);
  }
}
