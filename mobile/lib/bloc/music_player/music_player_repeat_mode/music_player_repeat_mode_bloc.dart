import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";

class MusicPlayerRepeatModeBloc
    extends Bloc<MusicPlayerRepeatModeEvent, MusicPlayerRepeatModeState> {
  MusicPlayerRepeatModeBloc() : super(MusicPlayerRepeatModeRepeatOffState()) {
    on<MusicPlayerRepeatModeChangeRepeatModeEvent>(
      _changeMusicPlayerRepeatMode,
    );
  }

  void _changeMusicPlayerRepeatMode(
    MusicPlayerRepeatModeChangeRepeatModeEvent event,
    Emitter<MusicPlayerRepeatModeState> emit,
  ) {
    if (state is MusicPlayerRepeatModeRepeatOffState) {
      emit(MusicPlayerRepeatModeRepeatAllState());
    } else if (state is MusicPlayerRepeatModeRepeatAllState) {
      emit(MusicPlayerRepeatModeRepeatOneState());
    } else {
      emit(MusicPlayerRepeatModeRepeatOffState());
    }
  }
}
