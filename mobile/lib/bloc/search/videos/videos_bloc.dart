import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/repositories/search_repo.dart";
import "package:wavelength/bloc/search/videos/videos_event.dart";
import "package:wavelength/bloc/search/videos/videos_state.dart";

class VideosBloc extends Bloc<VideosEvent, VideosState> {
  VideosBloc() : super(VideosDefaultState()) {
    on<VideosFetchEvent>(_fetchVideosByQuery);
  }

  Future<void> _fetchVideosByQuery(
    VideosFetchEvent event,
    Emitter<VideosState> emit,
  ) async {
    emit(VideosFetchLoadingState());
    final response = await SearchRepo.fetchVideosByQuery(query: event.query);

    if (response.success) {
      return emit(VideosFetchSuccessState(videos: response.data));
    }

    emit(VideosFetchErrorState());
  }
}
