import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";

class MusicPlayerPlaystateBloc
    extends Bloc<MusicPlayerPlaystateEvent, MusicPlayerPlaystateState> {
  final _musicPlayer = MusicPlayerSingleton();

  MusicPlayerPlaystateBloc() : super(MusicPlayerPlaystatePausedState()) {
    on<MusicPlayerPlaystateToggleEvent>(_toggleMusicPlayerPlaystate);
    on<MusicPlayerPlaystatePlayEvent>(_playMusicPlayerPlaystate);
    on<MusicPlayerPlaystatePauseEvent>(_pauseMusicPlayerPlaystate);
  }

  void _playMusicPlayerPlaystate(
    MusicPlayerPlaystatePlayEvent event,
    Emitter<MusicPlayerPlaystateState> emit,
  ) => emit(MusicPlayerPlaystatePlayingState());

  void _pauseMusicPlayerPlaystate(
    MusicPlayerPlaystatePauseEvent event,
    Emitter<MusicPlayerPlaystateState> emit,
  ) => emit(MusicPlayerPlaystatePausedState());

  void _toggleMusicPlayerPlaystate(
    MusicPlayerPlaystateToggleEvent event,
    Emitter<MusicPlayerPlaystateState> emit,
  ) {
    if (state is MusicPlayerPlaystatePausedState) {
      _musicPlayer.controller.play();
      emit(MusicPlayerPlaystatePlayingState());
    } else if (state is MusicPlayerPlaystatePlayingState) {
      _musicPlayer.controller.pause();
      emit(MusicPlayerPlaystatePausedState());
    }
  }
}
