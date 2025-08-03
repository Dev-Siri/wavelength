import "package:flutter/foundation.dart";
import "package:wavelength/api/models/artist_extra.dart";
import "package:wavelength/api/models/individual_artist.dart";

@immutable
abstract class ArtistState {}

class ArtistInitialState extends ArtistState {}

class ArtistLoadingState extends ArtistState {}

class ArtistErrorState extends ArtistState {}

class ArtistSuccessState extends ArtistState {
  final IndividualArtist artist;
  final ArtistExtra artistExtra;

  ArtistSuccessState({required this.artist, required this.artistExtra});
}
