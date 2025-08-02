import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/playlist_theme_color/playlist_theme_color_event.dart";
import "package:wavelength/bloc/playlist_theme_color/playlist_theme_color_state.dart";

class PlaylistThemeColorBloc
    extends Bloc<PlaylistThemeColorEvent, PlaylistThemeColorState> {
  PlaylistThemeColorBloc() : super(PlaylistThemeColorInitialState()) {
    on<PlaylistThemeColorFetchEvent>(_fetchPlaylistThemeColor);
  }

  Future<void> _fetchPlaylistThemeColor(
    PlaylistThemeColorFetchEvent event,
    Emitter<PlaylistThemeColorState> emit,
  ) async {
    emit(PlaylistThemeColorLoadingState());
    final response = await PlaylistsRepo.fetchPlaylistThemeColor(
      playlistId: event.playlistId,
      playlistImageUrl: event.playlistImageUrl,
    );

    if (response.success) {
      return emit(
        PlaylistThemeColorSuccessState(playlistThemeColor: response.data),
      );
    }

    emit(PlaylistThemeColorErrorState());
  }
}
