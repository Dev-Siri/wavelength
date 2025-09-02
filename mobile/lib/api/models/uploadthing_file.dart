class UploadThingFile {
  final String url;
  final String key;
  final String name;

  const UploadThingFile({
    required this.url,
    required this.key,
    required this.name,
  });

  factory UploadThingFile.fromJson(Map<String, dynamic> json) {
    return UploadThingFile(
      url: json["url"] as String,
      key: json["key"] as String,
      name: json["name"] as String,
    );
  }
}
