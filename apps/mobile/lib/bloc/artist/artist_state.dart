import "package:flutter/foundation.dart";
import "package:wavelength/api/models/artist.dart";

@immutable
sealed class ArtistState {}

class ArtistInitialState extends ArtistState {}

class ArtistLoadingState extends ArtistState {}

class ArtistErrorState extends ArtistState {}

class ArtistSuccessState extends ArtistState {
  final Artist artist;

  ArtistSuccessState({required this.artist});
}
