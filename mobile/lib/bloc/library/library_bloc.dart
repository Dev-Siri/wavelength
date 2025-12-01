import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/constants.dart";

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(LibraryDefaultState()) {
    on<LibraryPlaylistsFetchEvent>(_fetchUserPlaylists);
  }

  Future<void> _fetchUserPlaylists(
    LibraryPlaylistsFetchEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final box = await Hive.openBox(hivePlaylistsKey);
    final cachedPlaylists = (box.get(event.email) as List?)?.cast<Playlist>();

    if (cachedPlaylists != null) {
      emit(LibraryFetchSuccessState(playlists: cachedPlaylists));
    }

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    // Device is offline, avoid fetching.
    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    final response = await PlaylistsRepo.fetchUserPlaylists(
      email: event.email,
      authToken: event.authToken,
    );

    if (response is ApiResponseSuccess<List<Playlist>>) {
      await box.put(event.email, response.data);

      return emit(LibraryFetchSuccessState(playlists: response.data));
    }

    emit(LibraryFetchErrorState());
  }
}
