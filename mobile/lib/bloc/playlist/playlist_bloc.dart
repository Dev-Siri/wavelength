import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/bloc/playlist/playlist_state.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:hive/hive.dart";
import "package:wavelength/constants.dart";

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc() : super(PlaylistInitialState()) {
    on<PlaylistFetchEvent>(_fetchPlaylistAndTracks);
  }

  Future<void> _fetchPlaylistAndTracks(
    PlaylistFetchEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoadingState());

    final connectivityResult = await Connectivity().checkConnectivity();
    final box = await Hive.openBox(hivePlaylistsKey);

    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile)) {
      if (box.containsKey(event.playlistId)) {
        final cachedTracks = box.get(event.playlistId);
        emit(PlaylistSuccessState(songs: cachedTracks));
      }

      final response = await PlaylistsRepo.fetchPlaylistTracks(
        playlistId: event.playlistId,
      );

      if (response.success) {
        await box.put(event.playlistId, response.data);
        emit(PlaylistSuccessState(songs: response.data));
      }
    } else if (box.containsKey(event.playlistId)) {
      final cachedTracks = box.get(event.playlistId);
      emit(PlaylistSuccessState(songs: cachedTracks));
    }
  }
}
