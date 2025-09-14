import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";

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
    final player = MusicPlayerSingleton().player;

    if (state is MusicPlayerRepeatModeRepeatOffState) {
      player.setLoopMode(LoopMode.off);
      emit(MusicPlayerRepeatModeRepeatAllState());
    } else if (state is MusicPlayerRepeatModeRepeatAllState) {
      player.setLoopMode(LoopMode.all);
      emit(MusicPlayerRepeatModeRepeatOneState());
    } else {
      player.setLoopMode(LoopMode.one);
      emit(MusicPlayerRepeatModeRepeatOffState());
    }
  }
}
