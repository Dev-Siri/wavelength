import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/bloc/playlist/playlist_state.dart";

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc() : super(PlaylistInitialState()) {
    on<PlaylistFetchEvent>(_fetchPlaylistAndTracks);
  }

  Future<void> _fetchPlaylistTracksFromCache() {
    // Implement logic to fetch playlist tracks from cache if available
    // This is a placeholder for the actual implementation
    return Future.value();
  }

  Future<void> _fetchPlaylistAndTracks(
    PlaylistFetchEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoadingState());
    final response = await PlaylistsRepo.fetchPlaylistTracks(
      playlistId: event.playlistId,
    );

    if (response.success) {
      return emit(PlaylistSuccessState(songs: response.data));
    }

    emit(PlaylistErrorState());
  }
}
