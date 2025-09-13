import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist_extra.dart";
import "package:wavelength/api/models/individual_artist.dart";
import "package:wavelength/api/repositories/artist_repo.dart";
import "package:wavelength/bloc/artist/artist_event.dart";
import "package:wavelength/bloc/artist/artist_state.dart";

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  ArtistBloc() : super(ArtistInitialState()) {
    on<ArtistFetchEvent>(_fetchArtist);
  }

  Future<void> _fetchArtist(
    ArtistFetchEvent event,
    Emitter<ArtistState> emit,
  ) async {
    emit(ArtistLoadingState());
    final response = await ArtistRepo.fetchArtist(browseId: event.browseId);
    final extraResponse = await ArtistRepo.fetchArtistExtra(
      browseId: event.browseId,
    );

    if (response is ApiResponseSuccess<IndividualArtist> &&
        extraResponse is ApiResponseSuccess<ArtistExtra>) {
      return emit(
        ArtistSuccessState(
          artist: response.data,
          artistExtra: extraResponse.data,
        ),
      );
    }

    emit(ArtistErrorState());
  }
}
