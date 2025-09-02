import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";

class MusicPlayerDurationBloc
    extends Bloc<MusicPlayerDurationEvent, MusicPlayerDurationState> {
  final _musicPlayer = MusicPlayerSingleton();

  MusicPlayerDurationBloc() : super(MusicPlayerDurationUnavailableState()) {
    on<MusicPlayerDurationUpdateDurationEvent>(_updateMusicPlayerDuration);
    on<MusicPlayerDurationSeekToEvent>(_musicPlayerDurationSeekTo);
  }

  Future<void> _musicPlayerDurationSeekTo(
    MusicPlayerDurationSeekToEvent event,
    Emitter<MusicPlayerDurationState> emit,
  ) async {
    await _musicPlayer.player.seek(event.newDuration);

    emit(
      MusicPlayerDurationAvailableState(
        currentDuration: event.newDuration,
        totalDuration: event.totalDuration,
      ),
    );
  }

  void _updateMusicPlayerDuration(
    MusicPlayerDurationUpdateDurationEvent event,
    Emitter<MusicPlayerDurationState> emit,
  ) {
    emit(
      MusicPlayerDurationAvailableState(
        currentDuration: event.newDuration,
        totalDuration: event.totalDuration,
      ),
    );
  }
}
