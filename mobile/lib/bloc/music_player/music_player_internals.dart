import "dart:async";
import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";

class MusicPlayerInternals {
  final AudioPlayer _player;

  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;

  MusicPlayerInternals() : _player = MusicPlayerSingleton().player;

  void init(BuildContext context) {
    final musicPlayerDurationBloc = context.read<MusicPlayerDurationBloc>();
    final musicPlayerPlaystateBloc = context.read<MusicPlayerPlaystateBloc>();

    _positionSub = _player.positionStream.listen((position) {
      final musicPlayerDurationState = musicPlayerDurationBloc.state;

      musicPlayerDurationBloc.add(
        MusicPlayerDurationUpdateDurationEvent(
          newDuration: position,
          totalDuration:
              musicPlayerDurationState is MusicPlayerDurationAvailableState
              ? musicPlayerDurationState.totalDuration
              : Duration.zero,
        ),
      );
    });

    _durationSub = _player.durationStream.listen((duration) async {
      final musicPlayerDurationState = musicPlayerDurationBloc.state;

      if (duration != null) {
        musicPlayerDurationBloc.add(
          MusicPlayerDurationUpdateDurationEvent(
            newDuration:
                musicPlayerDurationState is MusicPlayerDurationAvailableState
                ? musicPlayerDurationState.currentDuration
                : Duration.zero,
            // The stream gets multiplied by 2 everytime its queried, yet that extra space is actually empty.
            // So its halved here just to account for that. Happens on all streams, so its not dangerous to do this.
            totalDuration: Platform.isIOS
                ? Duration(microseconds: duration.inMicroseconds ~/ 2)
                : duration,
          ),
        );
      }
    });

    _stateSub = _player.playerStateStream.listen((state) {
      if (state.playing) {
        musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePlayEvent());
        return;
      }

      musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePauseEvent());
    });
  }

  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _durationSub?.cancel();
  }
}
