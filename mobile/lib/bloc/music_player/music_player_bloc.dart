import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_event.dart";
import "package:wavelength/bloc/music_player/music_player_state.dart";

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  MusicPlayerBloc() : super(MusicPlayerState()) {
    on<MusicPlayerPlayMusicEvent>(
      (event, emit) => emit(MusicPlayerState(isPlaying: true)),
    );

    on<MusicPlayerPauseMusicEvent>(
      (event, emit) => emit(MusicPlayerState(isPlaying: false)),
    );

    on<MusicPlayerStopMusicEvent>(
      (event, emit) => emit(MusicPlayerState(isPlaying: false)),
    );
  }
}
