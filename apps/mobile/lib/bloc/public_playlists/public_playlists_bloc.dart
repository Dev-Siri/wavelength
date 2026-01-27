import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_event.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_state.dart";

class PublicPlaylistsBloc
    extends Bloc<PublicPlaylistsEvent, PublicPlaylistsState> {
  PublicPlaylistsBloc() : super(PublicPlaylistsDefaultState()) {
    on<PublicPlaylistsFetchEvent>(_fetchPublicPlaylists);
  }

  Future<void> _fetchPublicPlaylists(
    PublicPlaylistsFetchEvent event,
    Emitter<PublicPlaylistsState> emit,
  ) async {
    emit(PublicPlaylistsLoadingState());
    final response = await PlaylistsRepo.fetchPublicPlaylists(q: event.query);

    if (response is ApiResponseSuccess<List<Playlist>>) {
      return emit(PublicPlaylistsSuccessState(publicPlaylists: response.data));
    }

    emit(PublicPlaylistsErrorState());
  }
}
