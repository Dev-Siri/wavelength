import "package:flutter/foundation.dart";
import "package:wavelength/api/models/track.dart";

@immutable
sealed class TracksState {}

class TracksDefaultState extends TracksState {}

class TracksFetchLoadingState extends TracksState {}

class TracksFetchErrorState extends TracksState {}

class TracksFetchSuccessState extends TracksState {
  final List<Track> tracks;

  TracksFetchSuccessState({required this.tracks});
}
