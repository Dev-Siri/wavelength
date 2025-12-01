class IndividualArtistSongTrack {
  final String videoId;
  final String title;
  final String thumbnail;
  final String author;
  final bool isExplicit;

  const IndividualArtistSongTrack({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.author,
    required this.isExplicit,
  });

  factory IndividualArtistSongTrack.fromJson(Map<String, dynamic> json) {
    return IndividualArtistSongTrack(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
      isExplicit: json["isExplicit"] as bool,
    );
  }
}

class IndividualArtist {
  final String title;
  final String description;
  final String subscriberCount;
  final List<IndividualArtistSongTrack> topSongs;

  const IndividualArtist({
    required this.title,
    required this.description,
    required this.subscriberCount,
    required this.topSongs,
  });

  factory IndividualArtist.fromJson(Map<String, dynamic> json) {
    return IndividualArtist(
      title: json["title"] as String,
      description: json["description"] as String,
      subscriberCount: json["subscriberCount"] as String,
      topSongs: (json["topSongs"] as List)
          .map((final song) => IndividualArtistSongTrack.fromJson(song))
          .toList(),
    );
  }
}
