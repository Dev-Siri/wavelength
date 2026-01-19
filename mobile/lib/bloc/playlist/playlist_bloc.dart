import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/bloc/playlist/playlist_state.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:hive/hive.dart";
import "package:wavelength/constants.dart";

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc() : super(PlaylistInitialState()) {
    on<PlaylistFetchEvent>(_fetchPlaylistTracks);
  }

  Future<void> _fetchPlaylistTracks(
    PlaylistFetchEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoadingState());

    final connectivityResult = await Connectivity().checkConnectivity();

    final box = await Hive.openBox(hivePlaylistsTracksKey);

    final cachedPlaylistTracks = box
        .get(event.playlistId)
        ?.cast<PlaylistTrack>();

    if (cachedPlaylistTracks != null) {
      emit(PlaylistSuccessState(songs: cachedPlaylistTracks));
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return emit(PlaylistErrorState());
    }

    final response = await PlaylistsRepo.fetchPlaylistTracks(
      playlistId: event.playlistId,
    );

    if (response is ApiResponseSuccess<List<PlaylistTrack>>) {
      await box.put(event.playlistId, response.data);

      return emit(PlaylistSuccessState(songs: response.data));
    }

    emit(PlaylistErrorState());
  }
}
