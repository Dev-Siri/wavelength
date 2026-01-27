import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/album.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/album_repo.dart";
import "package:wavelength/bloc/album/album_event.dart";
import "package:wavelength/bloc/album/album_state.dart";
import "package:wavelength/constants.dart";

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  AlbumBloc() : super(const AlbumInitialState()) {
    on<AlbumFetchEvent>(_fetchAlbum);
  }

  Future<void> _fetchAlbum(
    AlbumFetchEvent event,
    Emitter<AlbumState> emit,
  ) async {
    emit(const AlbumFetchLoadingState());
    final box = await Hive.openBox(hiveAlbumsKey);
    final cachedAlbum = box.get(event.browseId);

    if (cachedAlbum != null) {
      emit(AlbumFetchSuccessState(album: cachedAlbum));
    }

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    final response = await AlbumRepo.fetchAlbum(browseId: event.browseId);

    if (response is ApiResponseSuccess<Album>) {
      await box.put(event.browseId, response.data);
      return emit(AlbumFetchSuccessState(album: response.data));
    }

    emit(const AlbumFetchErrorState());
  }
}
