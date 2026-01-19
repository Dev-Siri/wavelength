import "package:flutter/foundation.dart";
import "package:wavelength/api/models/album.dart";

@immutable
sealed class AlbumsState {}

class AlbumsDefaultState extends AlbumsState {}

class AlbumsFetchLoadingState extends AlbumsState {}

class AlbumsFetchErrorState extends AlbumsState {}

class AlbumsFetchSuccessState extends AlbumsState {
  final List<SearchAlbum> albums;

  AlbumsFetchSuccessState({required this.albums});
}
