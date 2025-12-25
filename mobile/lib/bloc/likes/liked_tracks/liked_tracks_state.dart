import "package:flutter/foundation.dart";
import "package:wavelength/api/models/liked_track.dart";

@immutable
sealed class LikedTracksState {}

class LikedTracksInitialState extends LikedTracksState {}

class LikedTracksFetchLoadingState extends LikedTracksState {}

class LikedTracksFetchSuccessState extends LikedTracksState {
  final List<LikedTrack> likedTracks;

  LikedTracksFetchSuccessState({required this.likedTracks});
}

class LikedTracksFetchErrorState extends LikedTracksState {}
