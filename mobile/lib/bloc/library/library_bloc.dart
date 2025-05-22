import "dart:async";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/library/library_state.dart";

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(LibraryDefaultState()) {
    on<LibraryPlaylistsFetchEvent>(_fetchUserPlaylists);
  }

  Future<void> _fetchUserPlaylists(
    LibraryPlaylistsFetchEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final response = await PlaylistsRepo.fetchUserPlaylists(email: event.email);

    if (response.success) {
      return emit(LibraryFetchSuccessState(playlists: response.data));
    }

    emit(LibraryFetchErrorState());
  }
}
