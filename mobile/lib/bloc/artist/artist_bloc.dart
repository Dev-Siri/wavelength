import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/repositories/artist_repo.dart";
import "package:wavelength/bloc/artist/artist_event.dart";
import "package:wavelength/bloc/artist/artist_state.dart";
import "package:wavelength/constants.dart";

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  ArtistBloc() : super(ArtistInitialState()) {
    on<ArtistFetchEvent>(_fetchArtist);
  }

  Future<void> _fetchArtist(
    ArtistFetchEvent event,
    Emitter<ArtistState> emit,
  ) async {
    emit(ArtistLoadingState());
    final box = await Hive.openBox(hiveArtistsKey);
    final cachedArtist = box.get(event.browseId);

    if (cachedArtist != null) {
      emit(ArtistSuccessState(artist: cachedArtist as Artist));
    }

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    final response = await ArtistRepo.fetchArtist(browseId: event.browseId);

    if (response is ApiResponseSuccess<Artist>) {
      await box.put(event.browseId, response.data);
      return emit(ArtistSuccessState(artist: response.data));
    }

    emit(ArtistErrorState());
  }
}
