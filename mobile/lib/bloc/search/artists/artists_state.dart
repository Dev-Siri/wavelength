import "package:flutter/foundation.dart";
import "package:wavelength/api/models/artist.dart";

@immutable
sealed class ArtistsState {}

class ArtistsDefaultState extends ArtistsState {}

class ArtistsFetchLoadingState extends ArtistsState {}

class ArtistsFetchErrorState extends ArtistsState {}

class ArtistsFetchSuccessState extends ArtistsState {
  final List<SearchArtist> artists;

  ArtistsFetchSuccessState({required this.artists});
}
