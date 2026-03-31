import "package:flutter/foundation.dart";
import "package:wavelength/api/models/track.dart";

@immutable
sealed class RecommendedSongsState {}

class RecommendedSongsInitialState extends RecommendedSongsState {}

class RecommendedSongsLoadingState extends RecommendedSongsState {}

class RecommendedSongsErrorState extends RecommendedSongsState {}

class RecommendedSongsSuccessState extends RecommendedSongsState {
  final List<Track> tracks;

  RecommendedSongsSuccessState({required this.tracks});
}
