class Artist {
  final String browseId;
  final String title;
  final String thumbnail;
  final String author;
  final String subscriberText;
  final bool isExplicit;

  const Artist({
    required this.browseId,
    required this.title,
    required this.thumbnail,
    required this.author,
    required this.subscriberText,
    required this.isExplicit,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      browseId: json["browseId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
      subscriberText: json["subscriberText"] as String,
      isExplicit: json["isExplicit"] as bool,
    );
  }
}
