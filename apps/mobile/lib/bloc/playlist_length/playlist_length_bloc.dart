import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_event.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_state.dart";
import "package:wavelength/constants.dart";

class PlaylistLengthBloc
    extends Bloc<PlaylistLengthEvent, PlaylistLengthState> {
  PlaylistLengthBloc() : super(PlaylistLengthInitialState()) {
    on<PlaylistLengthFetchEvent>(_fetchPlaylistTracksLength);
  }

  Future<void> _fetchPlaylistTracksLength(
    PlaylistLengthFetchEvent event,
    Emitter<PlaylistLengthState> emit,
  ) async {
    final playlengthsStore = await Hive.openBox(hivePlaylengthKey);
    final cachedTracksLength = playlengthsStore.get(event.playlistId);

    if (cachedTracksLength != null) {
      emit(
        PlaylistLengthSuccessState(playlistTracksLength: cachedTracksLength),
      );
    }

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    emit(PlaylistLengthLoadingState());
    final response = await PlaylistsRepo.fetchPlaylistTracksLength(
      playlistId: event.playlistId,
    );

    if (response is ApiResponseSuccess<PlaylistTracksLength>) {
      await playlengthsStore.put(event.playlistId, response.data);
      return emit(
        PlaylistLengthSuccessState(playlistTracksLength: response.data),
      );
    }

    emit(PlaylistLengthErrorState());
  }
}
