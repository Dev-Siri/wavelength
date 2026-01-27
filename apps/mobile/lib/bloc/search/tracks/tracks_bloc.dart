import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/search_repo.dart";
import "package:wavelength/bloc/search/tracks/tracks_event.dart";
import "package:wavelength/bloc/search/tracks/tracks_state.dart";

class TracksBloc extends Bloc<TracksEvent, TracksState> {
  TracksBloc() : super(TracksDefaultState()) {
    on<TracksFetchEvent>(_fetchTracksByQuery);
  }

  Future<void> _fetchTracksByQuery(
    TracksFetchEvent event,
    Emitter<TracksState> emit,
  ) async {
    emit(TracksFetchLoadingState());
    final response = await SearchRepo.fetchTracksByQuery(query: event.query);

    if (response is ApiResponseSuccess<List<Track>>) {
      return emit(TracksFetchSuccessState(tracks: response.data));
    }

    emit(TracksFetchErrorState());
  }
}
