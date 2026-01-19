import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/repositories/artist_repo.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/constants.dart";

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryDefaultState()) {
    on<LibraryFetchEvent>(_fetchLibrary);
  }

  Future<void> _fetchLibrary(
    LibraryFetchEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final playlistsBox = await Hive.openBox(hivePlaylistsKey);
    final followedArtistsBox = await Hive.openBox(hiveFollowedArtistsKey);

    final cachedPlaylists = (playlistsBox.get(event.email) as List?)
        ?.cast<Playlist>();
    final followedArtists = (followedArtistsBox.get(event.email) as List?)
        ?.cast<FollowedArtist>();

    if (cachedPlaylists != null || followedArtists != null) {
      emit(
        LibraryFetchSuccessState(
          playlists: cachedPlaylists ?? [],
          followedArtists: followedArtists ?? [],
        ),
      );
    }

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    // Device is offline, avoid fetching.
    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    final playlistsResponse = await PlaylistsRepo.fetchUserPlaylists(
      email: event.email,
      authToken: event.authToken,
    );

    if (playlistsResponse is ApiResponseSuccess<List<Playlist>>) {
      await playlistsBox.put(event.email, playlistsResponse.data);

      emit(
        LibraryFetchSuccessState(
          playlists: playlistsResponse.data,
          followedArtists: state is LibraryFetchSuccessState
              ? (state as LibraryFetchSuccessState).followedArtists
              : [],
        ),
      );
    } else if (playlistsResponse is ApiResponseError<List<Playlist>>) {
      return emit(const LibraryFetchErrorState());
    }

    final followedArtistsResponse = await ArtistRepo.fetchFollowedArtists(
      authToken: event.authToken,
    );

    if (followedArtistsResponse is ApiResponseSuccess<List<FollowedArtist>>) {
      await followedArtistsBox.put(event.email, followedArtistsResponse.data);

      return emit(
        LibraryFetchSuccessState(
          playlists: state is LibraryFetchSuccessState
              ? (state as LibraryFetchSuccessState).playlists
              : [],
          followedArtists: followedArtistsResponse.data,
        ),
      );
    } else {
      return emit(const LibraryFetchErrorState());
    }
  }
}
