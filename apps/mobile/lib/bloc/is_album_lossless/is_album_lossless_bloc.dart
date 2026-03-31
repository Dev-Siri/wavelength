import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/album_repo.dart";
import "package:wavelength/bloc/is_album_lossless/is_album_lossless_event.dart";
import "package:wavelength/bloc/is_album_lossless/is_album_lossless_state.dart";
import "package:wavelength/constants.dart";

class IsAlbumLosslessBloc
    extends Bloc<IsAlbumLosslessEvent, IsAlbumLosslessState> {
  IsAlbumLosslessBloc() : super(IsAlbumLosslessInitialState()) {
    on<IsAlbumLosslessFetchEvent>(_fetchIsAlbumLossless);
  }

  Future<void> _fetchIsAlbumLossless(
    IsAlbumLosslessFetchEvent event,
    Emitter<IsAlbumLosslessState> emit,
  ) async {
    final box = await Hive.openBox(hiveIsAlbumLosslessKey);

    if (box.containsKey(event.albumId)) {
      return emit(IsAlbumLosslessSuccessState(isLossless: true));
    }

    final isAlbumLosslessResponse = await AlbumRepo.fetchIsAlbumLossless(
      albumId: event.albumId,
    );

    if (isAlbumLosslessResponse is ApiResponseSuccess<bool>) {
      await box.put(event.albumId, true);
      emit(
        IsAlbumLosslessSuccessState(isLossless: isAlbumLosslessResponse.data),
      );
    }
  }
}
