import "package:flutter/foundation.dart";
import "package:wavelength/api/models/artist.dart";

@immutable
class ArtistsState {}

class ArtistsDefaultState extends ArtistsState {}

class ArtistsFetchLoadingState extends ArtistsState {}

class ArtistsFetchErrorState extends ArtistsState {}

class ArtistsFetchSuccessState extends ArtistsState {
  final List<Artist> artists;

  ArtistsFetchSuccessState({required this.artists});
}
