import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_event.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_state.dart";

class PlaylistLengthBloc
    extends Bloc<PlaylistLengthEvent, PlaylistLengthState> {
  PlaylistLengthBloc() : super(PlaylistLengthInitialState()) {
    on<PlaylistLengthFetchEvent>(_fetchPlaylistTracksLength);
  }

  Future<void> _fetchPlaylistTracksLength(
    PlaylistLengthFetchEvent event,
    Emitter<PlaylistLengthState> emit,
  ) async {
    emit(PlaylistLengthLoadingState());
    final response = await PlaylistsRepo.fetchPlaylistTracksLength(
      playlistId: event.playlistId,
    );

    if (response is ApiResponseSuccess<PlaylistTracksLength>) {
      return emit(
        PlaylistLengthSuccessState(playlistTracksLength: response.data),
      );
    }

    emit(PlaylistLengthErrorState());
  }
}
