import "package:wavelength/audio/queueable_music.dart";

sealed class MusicContextType {}

class MusicContextTypeNone extends MusicContextType {}

class MusicContextTypeDownloads extends MusicContextType {}

class MusicContextTypePlaylist extends MusicContextType {
  final String playlistId;

  MusicContextTypePlaylist({required this.playlistId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MusicContextTypePlaylist && other.playlistId == playlistId;
  }

  @override
  int get hashCode => playlistId.hashCode;
}

class MusicContextTypeAlbum extends MusicContextType {
  final String albumId;

  MusicContextTypeAlbum({required this.albumId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MusicContextTypeAlbum && other.albumId == albumId;
  }

  @override
  int get hashCode => albumId.hashCode;
}

class MusicContextTypeLikes extends MusicContextType {
  final String authToken;

  MusicContextTypeLikes({required this.authToken});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MusicContextTypeLikes && other.authToken == authToken;
  }

  @override
  int get hashCode => authToken.hashCode;
}

class MusicContextTypeArtistTopSongs extends MusicContextType {
  final String artistId;

  MusicContextTypeArtistTopSongs({required this.artistId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MusicContextTypeArtistTopSongs &&
        other.artistId == artistId;
  }

  @override
  int get hashCode => artistId.hashCode;
}

class MusicContextQueue {
  final String? sourceLabel;
  final MusicContextType type;
  final List<QueueableMusic> queue;

  const MusicContextQueue({
    required this.sourceLabel,
    required this.type,
    required this.queue,
  });
}
