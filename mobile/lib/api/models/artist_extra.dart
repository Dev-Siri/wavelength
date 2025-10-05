class ArtistExtra {
  final String thumbnail;

  const ArtistExtra({required this.thumbnail});

  factory ArtistExtra.fromJson(Map<String, dynamic> json) {
    return ArtistExtra(thumbnail: json["thumbnail"] as String);
  }
}
