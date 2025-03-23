import "package:flutter/cupertino.dart";
import "package:wavelength/api/models/playlist.dart";

@immutable
abstract class PublicPlaylistsState {}

class PublicPlaylistsDefaultState extends PublicPlaylistsState {}

class PublicPlaylistsLoadingState extends PublicPlaylistsState {}

class PublicPlaylistsSuccessState extends PublicPlaylistsState {
  final List<Playlist> publicPlaylists;

  PublicPlaylistsSuccessState({required this.publicPlaylists});
}

class PublicPlaylistsErrorState extends PublicPlaylistsState {}
