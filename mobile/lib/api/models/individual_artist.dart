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
}

class IndividualArtistSong {
  final String browseId;
  final String titleHeader;
  final List<IndividualArtistSongTrack> contents;

  const IndividualArtistSong({
    required this.browseId,
    required this.titleHeader,
    required this.contents,
  });
}

class IndividualArtist {
  final String title;
  final String description;
  final String thumbnail;
  final String subscriberCount;
  final List<IndividualArtistSong> songs;

  const IndividualArtist({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.subscriberCount,
    required this.songs,
  });

  factory IndividualArtist.fromJson(Map<String, dynamic> json) {
    return IndividualArtist(
      title: json["title"] as String,
      description: json["description"] as String,
      thumbnail: json["thumbnail"] as String,
      subscriberCount: json["subscriberCount"] as String,
      songs:
          ((json["songs"] as List?)
                  ?.map(
                    (songJson) => IndividualArtistSong(
                      browseId: songJson["browseId"] as String,
                      titleHeader: songJson["titleHeader"] as String,
                      contents:
                          ((songJson["contents"] as List?)
                                  ?.map(
                                    (
                                      songContentsJson,
                                    ) => IndividualArtistSongTrack(
                                      videoId:
                                          songContentsJson["videoId"] as String,
                                      title:
                                          songContentsJson["title"] as String,
                                      thumbnail:
                                          songContentsJson["thumbnail"]
                                              as String,
                                      author:
                                          songContentsJson["author"] as String,
                                      isExplicit:
                                          songContentsJson["isExplicit"]
                                              as bool,
                                    ),
                                  )
                                  .toList() ??
                              List.empty()),
                    ),
                  )
                  .toList() ??
              List.empty()),
    );
  }
}
