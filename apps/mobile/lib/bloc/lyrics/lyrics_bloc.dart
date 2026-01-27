import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/lyric.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/lyrics/lyrics_event.dart";
import "package:wavelength/bloc/lyrics/lyrics_state.dart";
import "package:wavelength/constants.dart";

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  LyricsBloc() : super(LyricsInitialState()) {
    on<LyricsFetchEvent>(_fetchTrackLyrics);
  }

  Future<void> _fetchTrackLyrics(
    LyricsFetchEvent event,
    Emitter<LyricsState> emit,
  ) async {
    final box = await Hive.openBox(hiveLyricsKey);
    final cachedLyrics = (box.get(event.trackId) as List?)?.cast<Lyric>();

    if (cachedLyrics != null) {
      emit(LyricsFetchSuccessState(lyrics: cachedLyrics));
      return;
    }

    emit(LyricsFetchLoadingState());

    final response = await TrackRepo.fetchTrackLyrics(trackId: event.trackId);

    if (response is ApiResponseSuccess<List<Lyric>>) {
      await box.put(event.trackId, response.data);

      return emit(LyricsFetchSuccessState(lyrics: response.data.cast<Lyric>()));
    }

    emit(LyricsFetchErrorState());
  }
}
