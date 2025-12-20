import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";

class MusicPlayerRepeatModeBloc
    extends Bloc<MusicPlayerRepeatModeEvent, MusicPlayerRepeatModeState> {
  MusicPlayerRepeatModeBloc() : super(MusicPlayerRepeatModeRepeatOffState()) {
    on<MusicPlayerRepeatModeOffEvent>(_turnOffRepeatMode);
    on<MusicPlayerRepeatModeAllEvent>(_turnOnRepeatAllMode);
    on<MusicPlayerRepeatModeOneEvent>(_turnOnRepeatOneMode);
  }

  void _turnOffRepeatMode(
    MusicPlayerRepeatModeOffEvent event,
    Emitter<MusicPlayerRepeatModeState> emit,
  ) {
    if (state is! MusicPlayerRepeatModeRepeatOffState) {
      emit(MusicPlayerRepeatModeRepeatOffState());
    }
  }

  void _turnOnRepeatAllMode(
    MusicPlayerRepeatModeAllEvent event,
    Emitter<MusicPlayerRepeatModeState> emit,
  ) {
    if (state is! MusicPlayerRepeatModeRepeatAllState) {
      emit(MusicPlayerRepeatModeRepeatAllState());
    }
  }

  void _turnOnRepeatOneMode(
    MusicPlayerRepeatModeOneEvent event,
    Emitter<MusicPlayerRepeatModeState> emit,
  ) {
    if (state is! MusicPlayerRepeatModeRepeatOneState) {
      emit(MusicPlayerRepeatModeRepeatOneState());
    }
  }
}
