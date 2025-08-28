import "package:flutter/foundation.dart";
import "package:wavelength/api/models/playlist_track.dart";

@immutable
sealed class PlaylistState {}

class PlaylistInitialState extends PlaylistState {}

class PlaylistLoadingState extends PlaylistState {}

class PlaylistErrorState extends PlaylistState {}

class PlaylistSuccessState extends PlaylistState {
  final List<PlaylistTrack> songs;

  PlaylistSuccessState({required this.songs});
}
