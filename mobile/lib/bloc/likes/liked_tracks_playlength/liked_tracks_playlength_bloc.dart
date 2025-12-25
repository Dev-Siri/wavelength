import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_event.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_state.dart";

class LikedTracksPlaylengthBloc
    extends Bloc<LikedTracksPlaylengthEvent, LikedTracksPlaylengthState> {
  LikedTracksPlaylengthBloc() : super(LikedTracksPlaylengthInitialState()) {
    on<LikedTracksPlaylengthFetchEvent>(_fetchLikedTracksPlaylength);
  }

  Future<void> _fetchLikedTracksPlaylength(
    LikedTracksPlaylengthFetchEvent event,
    Emitter<LikedTracksPlaylengthState> emit,
  ) async {
    emit(LikedTracksPlaylengthLoadingState());
    final response = await TrackRepo.fetchLikedTracksLength(
      authToken: event.authToken,
    );

    if (response is ApiResponseSuccess<PlaylistTracksLength>) {
      return emit(
        LikedTracksPlaylengthSuccessState(likesPlaylength: response.data),
      );
    }

    emit(LikedTracksPlaylengthErrorState());
  }
}
