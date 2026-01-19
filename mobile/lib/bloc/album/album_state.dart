import "package:flutter/foundation.dart";
import "package:wavelength/api/models/album.dart";

@immutable
sealed class AlbumState {
  const AlbumState();
}

class AlbumInitialState extends AlbumState {
  const AlbumInitialState();
}

class AlbumFetchLoadingState extends AlbumState {
  const AlbumFetchLoadingState();
}

class AlbumFetchSuccessState extends AlbumState {
  final Album album;

  const AlbumFetchSuccessState({required this.album});
}

class AlbumFetchErrorState extends AlbumState {
  const AlbumFetchErrorState();
}
