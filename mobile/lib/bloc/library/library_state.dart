import "package:flutter/foundation.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/models/playlist.dart";

@immutable
sealed class LibraryState {
  const LibraryState();
}

class LibraryDefaultState extends LibraryState {
  const LibraryDefaultState();
}

class LibraryFetchLoadingState extends LibraryState {
  const LibraryFetchLoadingState();
}

class LibraryFetchErrorState extends LibraryState {
  const LibraryFetchErrorState();
}

class LibraryFetchSuccessState extends LibraryState {
  final List<Playlist> playlists;
  final List<FollowedArtist> followedArtists;

  const LibraryFetchSuccessState({
    required this.playlists,
    required this.followedArtists,
  });
}
