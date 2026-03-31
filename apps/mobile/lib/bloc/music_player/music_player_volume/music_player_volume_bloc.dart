import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";

class MusicPlayerVolumeBloc
    extends Bloc<MusicPlayerVolumeEvent, MusicPlayerVolumeState> {
  final WavelengthAudioHandler _audioHandler;

  MusicPlayerVolumeBloc(this._audioHandler)
    : super(MusicPlayerVolumeUnmutedState()) {
    on<MusicPlayerVolumeMuteEvent>(_muteTrack);
    on<MusicPlayerVolumeUnmuteEvent>(_unmuteTrack);
  }

  void _muteTrack(
    MusicPlayerVolumeMuteEvent event,
    Emitter<MusicPlayerVolumeState> emit,
  ) {
    _audioHandler.mute();
    emit(MusicPlayerVolumeMutedState());
  }

  void _unmuteTrack(
    MusicPlayerVolumeUnmuteEvent event,
    Emitter<MusicPlayerVolumeState> emit,
  ) {
    _audioHandler.unMute();
    emit(MusicPlayerVolumeUnmutedState());
  }
}
