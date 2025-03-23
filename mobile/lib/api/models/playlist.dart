class Playlist {
  final String playlistId;
  final String name;
  final String authorGoogleEmail;
  final String authorName;
  final String authorImage;
  final String? coverImage;
  final bool isPublic;

  const Playlist({
    required this.playlistId,
    required this.name,
    required this.authorGoogleEmail,
    required this.authorImage,
    required this.authorName,
    required this.coverImage,
    required this.isPublic,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json["playlistId"] as String,
      name: json["name"] as String,
      authorGoogleEmail: json["authorGoogleEmail"] as String,
      authorName: json["authorName"] as String,
      authorImage: json["authorImage"] as String,
      coverImage: json["coverImage"] as String?,
      isPublic: json["isPublic"] as bool,
    );
  }
}
