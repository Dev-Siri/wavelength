import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/liked_track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_event.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_state.dart";
import "package:wavelength/constants.dart";

class LikedTracksBloc extends Bloc<LikedTracksEvent, LikedTracksState> {
  LikedTracksBloc() : super(LikedTracksInitialState()) {
    on<LikedTracksFetchEvent>(_fetchLikedTracks);
  }

  Future<void> _fetchLikedTracks(
    LikedTracksFetchEvent event,
    Emitter<LikedTracksState> emit,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    final box = await Hive.openBox(hiveLikesKey);

    final cachedPlaylistTracks = box.get(event.email)?.cast<LikedTrack>();

    if (cachedPlaylistTracks != null) {
      emit(LikedTracksFetchSuccessState(likedTracks: cachedPlaylistTracks));
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return emit(LikedTracksFetchErrorState());
    }

    final response = await TrackRepo.fetchLikedTracks(
      authToken: event.authToken,
    );

    if (response is ApiResponseSuccess<List<LikedTrack>>) {
      await box.put(event.email, response.data);

      return emit(LikedTracksFetchSuccessState(likedTracks: response.data));
    }

    emit(LikedTracksFetchErrorState());
  }
}
