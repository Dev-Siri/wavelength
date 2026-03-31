import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/album_repo.dart";
import "package:wavelength/bloc/live_album_cover/live_album_cover_event.dart";
import "package:wavelength/bloc/live_album_cover/live_album_cover_state.dart";

class LiveAlbumCoverBloc
    extends Bloc<LiveAlbumCoverEvent, LiveAlbumCoverState> {
  LiveAlbumCoverBloc() : super(LiveAlbumCoverFetchInitialState()) {
    on<LiveAlbumCoverFetchEvent>(_fetchLiveAlbumCover);
  }

  Future<void> _fetchLiveAlbumCover(
    LiveAlbumCoverFetchEvent event,
    Emitter<LiveAlbumCoverState> emit,
  ) async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return emit(LiveAlbumCoverFetchSuccessState(liveAlbumCoverUri: null));
    }

    final albumCover = await AlbumRepo.fetchLiveAlbumCover(
      albumId: event.albumId,
      videoId: event.videoId,
    );

    if (albumCover is ApiResponseSuccess<String?>) {
      return emit(
        LiveAlbumCoverFetchSuccessState(liveAlbumCoverUri: albumCover.data),
      );
    }

    emit(LiveAlbumCoverFetchErrorState());
  }
}
