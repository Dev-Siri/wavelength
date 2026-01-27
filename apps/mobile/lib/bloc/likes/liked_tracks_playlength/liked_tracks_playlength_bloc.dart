import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_event.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_state.dart";
import "package:wavelength/constants.dart";

class LikedTracksPlaylengthBloc
    extends Bloc<LikedTracksPlaylengthEvent, LikedTracksPlaylengthState> {
  static const likesKey = "likes";

  LikedTracksPlaylengthBloc() : super(LikedTracksPlaylengthInitialState()) {
    on<LikedTracksPlaylengthFetchEvent>(_fetchLikedTracksPlaylength);
  }

  Future<void> _fetchLikedTracksPlaylength(
    LikedTracksPlaylengthFetchEvent event,
    Emitter<LikedTracksPlaylengthState> emit,
  ) async {
    final playlengthsStore = await Hive.openBox(hivePlaylengthKey);
    final cachedTracksLength = playlengthsStore.get(likesKey);

    if (cachedTracksLength != null) {
      emit(
        LikedTracksPlaylengthSuccessState(likesPlaylength: cachedTracksLength),
      );
    }

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    emit(LikedTracksPlaylengthLoadingState());
    final response = await TrackRepo.fetchLikedTracksLength(
      authToken: event.authToken,
    );

    if (response is ApiResponseSuccess<PlaylistTracksLength>) {
      await playlengthsStore.put(likesKey, response.data);
      return emit(
        LikedTracksPlaylengthSuccessState(likesPlaylength: response.data),
      );
    }

    emit(LikedTracksPlaylengthErrorState());
  }
}
