import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/album.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/search_repo.dart";
import "package:wavelength/bloc/search/albums/albums_event.dart";
import "package:wavelength/bloc/search/albums/albums_state.dart";

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc() : super(AlbumsDefaultState()) {
    on<AlbumsFetchEvent>(_fetchAlbumsByQuery);
  }

  Future<void> _fetchAlbumsByQuery(
    AlbumsFetchEvent event,
    Emitter<AlbumsState> emit,
  ) async {
    emit(AlbumsFetchLoadingState());
    final response = await SearchRepo.fetchAlbumsByQuery(query: event.query);

    if (response is ApiResponseSuccess<List<Album>>) {
      return emit(AlbumsFetchSuccessState(albums: response.data));
    }

    emit(AlbumsFetchErrorState());
  }
}
