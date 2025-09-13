import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/repositories/search_repo.dart";
import "package:wavelength/bloc/search/artists/artists_event.dart";
import "package:wavelength/bloc/search/artists/artists_state.dart";

class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  ArtistsBloc() : super(ArtistsDefaultState()) {
    on<ArtistsFetchEvent>(_fetchArtistsByQuery);
  }

  Future<void> _fetchArtistsByQuery(
    ArtistsFetchEvent event,
    Emitter<ArtistsState> emit,
  ) async {
    emit(ArtistsFetchLoadingState());
    final response = await SearchRepo.fetchArtistsByQuery(query: event.query);

    if (response is ApiResponseSuccess<List<Artist>>) {
      return emit(ArtistsFetchSuccessState(artists: response.data));
    }

    emit(ArtistsFetchErrorState());
  }
}
