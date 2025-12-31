class Album {
  final String albumId;
  final String albumType;
  final String title;
  final String thumbnail;
  final String author;
  final String releaseDate;
  final bool isExplicit;

  Album({
    required this.albumId,
    required this.albumType,
    required this.title,
    required this.thumbnail,
    required this.author,
    required this.releaseDate,
    required this.isExplicit,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      albumId: json["albumId"] as String,
      albumType: json["albumType"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
      releaseDate: json["releaseDate"] as String,
      isExplicit: json["isExplicit"] as bool,
    );
  }
}
