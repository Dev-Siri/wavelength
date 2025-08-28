import "package:flutter/foundation.dart";
import "package:wavelength/api/models/playlist.dart";

@immutable
sealed class LibraryState {}

class LibraryDefaultState extends LibraryState {}

class LibraryFetchLoadingState extends LibraryState {}

class LibraryFetchErrorState extends LibraryState {}

class LibraryFetchSuccessState extends LibraryState {
  final List<Playlist> playlists;

  LibraryFetchSuccessState({required this.playlists});
}
