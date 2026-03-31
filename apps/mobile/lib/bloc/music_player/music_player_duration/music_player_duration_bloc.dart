import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";

class MusicPlayerDurationBloc
    extends Bloc<MusicPlayerDurationEvent, MusicPlayerDurationState> {
  final WavelengthAudioHandler _audioHandler;

  MusicPlayerDurationBloc(this._audioHandler)
    : super(MusicPlayerDurationUnavailableState()) {
    on<MusicPlayerDurationUpdateDurationEvent>(_updateMusicPlayerDuration);
    on<MusicPlayerDurationSeekToEvent>(_musicPlayerDurationSeekTo);
  }

  Future<void> _musicPlayerDurationSeekTo(
    MusicPlayerDurationSeekToEvent event,
    Emitter<MusicPlayerDurationState> emit,
  ) async {
    await _audioHandler.seek(event.newDuration);

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
