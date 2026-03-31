import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/recommended_songs/recommended_songs_event.dart";
import "package:wavelength/bloc/recommended_songs/recommended_songs_state.dart";

class RecommendedSongsBloc
    extends Bloc<RecommendedSongsEvent, RecommendedSongsState> {
  RecommendedSongsBloc() : super(RecommendedSongsInitialState()) {
    on<RecommendedSongsFetchEvent>(_fetchRecommendedSongs);
  }

  Future<void> _fetchRecommendedSongs(
    RecommendedSongsFetchEvent event,
    Emitter<RecommendedSongsState> emit,
  ) async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return emit(RecommendedSongsInitialState());
    }

    emit(RecommendedSongsLoadingState());
    final songsResponse = await PlaylistsRepo.fetchRecommendedSongs(
      playlistId: event.playlistId,
    );

    if (songsResponse is ApiResponseSuccess<List<Track>>) {
      return emit(RecommendedSongsSuccessState(tracks: songsResponse.data));
    }

    emit(RecommendedSongsErrorState());
  }
}
