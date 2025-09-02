import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";

class MusicPlayerVolumeBloc
    extends Bloc<MusicPlayerVolumeEvent, MusicPlayerVolumeState> {
  final _musicPlayer = MusicPlayerSingleton();

  MusicPlayerVolumeBloc() : super(MusicPlayerVolumeUnmutedState()) {
    on<MusicPlayerVolumeMuteEvent>(_muteTrack);
    on<MusicPlayerVolumeUnmuteEvent>(_unmuteTrack);
  }

  void _muteTrack(
    MusicPlayerVolumeMuteEvent event,
    Emitter<MusicPlayerVolumeState> emit,
  ) {
    _musicPlayer.player.setVolume(0);

    emit(MusicPlayerVolumeMutedState());
  }

  void _unmuteTrack(
    MusicPlayerVolumeUnmuteEvent event,
    Emitter<MusicPlayerVolumeState> emit,
  ) {
    _musicPlayer.player.setVolume(1);

    emit(MusicPlayerVolumeUnmutedState());
  }
}
