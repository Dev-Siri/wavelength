import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_state.dart";

class MusicPlayerShuffleModeBloc
    extends Bloc<MusicPlayerShuffleModeEvent, MusicPlayerShuffleModeState> {
  MusicPlayerShuffleModeBloc()
    : super(MusicPlayerShuffleModeShuffleOffState()) {
    on<MusicPlayerShuffleModeOffEvent>(_turnOffShuffleMode);
    on<MusicPlayerShuffleModeAllEvent>(_turnOnShuffleAllMode);
  }

  void _turnOffShuffleMode(
    MusicPlayerShuffleModeOffEvent event,
    Emitter<MusicPlayerShuffleModeState> emit,
  ) {
    if (state is! MusicPlayerShuffleModeShuffleOffState) {
      emit(MusicPlayerShuffleModeShuffleOffState());
    }
  }

  void _turnOnShuffleAllMode(
    MusicPlayerShuffleModeAllEvent event,
    Emitter<MusicPlayerShuffleModeState> emit,
  ) {
    if (state is! MusicPlayerShuffleModeShuffleAllState) {
      emit(MusicPlayerShuffleModeShuffleAllState());
    }
  }
}
