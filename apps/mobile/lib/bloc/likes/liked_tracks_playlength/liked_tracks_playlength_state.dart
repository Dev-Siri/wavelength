import "package:flutter/foundation.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";

@immutable
sealed class LikedTracksPlaylengthState {}

class LikedTracksPlaylengthInitialState extends LikedTracksPlaylengthState {}

class LikedTracksPlaylengthLoadingState extends LikedTracksPlaylengthState {}

class LikedTracksPlaylengthSuccessState extends LikedTracksPlaylengthState {
  final PlaylistTracksLength likesPlaylength;

  LikedTracksPlaylengthSuccessState({required this.likesPlaylength});
}

class LikedTracksPlaylengthErrorState extends LikedTracksPlaylengthState {}
