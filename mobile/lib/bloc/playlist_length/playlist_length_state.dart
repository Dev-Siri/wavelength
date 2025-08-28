import "package:flutter/foundation.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";

@immutable
sealed class PlaylistLengthState {}

class PlaylistLengthInitialState extends PlaylistLengthState {}

class PlaylistLengthLoadingState extends PlaylistLengthState {}

class PlaylistLengthErrorState extends PlaylistLengthState {}

class PlaylistLengthSuccessState extends PlaylistLengthState {
  final PlaylistTracksLength playlistTracksLength;

  PlaylistLengthSuccessState({required this.playlistTracksLength});
}
