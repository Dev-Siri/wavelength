import "dart:async";

import "package:flutter/widgets.dart";
import "package:just_audio/just_audio.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";

class PlayerUiSync {
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _currentSequenceSub;
  StreamSubscription? _loopModeSub;
  StreamSubscription? _shuffleModeSub;
  StreamSubscription? _processingStateSub;

  void init(BuildContext context) {
    final player = context.read<WavelengthAudioHandler>();
    final musicPlayerDurationBloc = context.read<MusicPlayerDurationBloc>();
    final musicPlayerPlaystateBloc = context.read<MusicPlayerPlaystateBloc>();
    final musicPlayerTrackBloc = context.read<MusicPlayerTrackBloc>();
    final musicPlayerRepeatModeBloc = context.read<MusicPlayerRepeatModeBloc>();
    final musicPlayerShuffleModeBloc = context
        .read<MusicPlayerShuffleModeBloc>();

    _positionSub = player.onTimeChange.listen((time) async {
      final musicPlayerDurationState = musicPlayerDurationBloc.state;

      final totalDuration =
          musicPlayerDurationState is MusicPlayerDurationAvailableState
          ? musicPlayerDurationState.totalDuration
          : Duration.zero;

      musicPlayerDurationBloc.add(
        MusicPlayerDurationUpdateDurationEvent(
          newDuration: time,
          totalDuration: totalDuration,
        ),
      );
    });

    _currentSequenceSub = player.onTrackChange.listen((event) {
      if (event == null) return;

      final musicPlayerDurationState = musicPlayerDurationBloc.state;
      final currentDuration =
          musicPlayerDurationState is MusicPlayerDurationAvailableState
          ? musicPlayerDurationState.currentDuration
          : Duration.zero;

      musicPlayerDurationBloc.add(
        MusicPlayerDurationUpdateDurationEvent(
          totalDuration: Duration(seconds: event.track.duration),
          newDuration: currentDuration,
        ),
      );

      musicPlayerTrackBloc.add(
        MusicPlayerTrackAutoLoadEvent(
          metadata: event.metadata,
          queueableMusic: event.track,
        ),
      );
    });

    _stateSub = player.onPlaystateChange.listen((isPlaying) {
      if (isPlaying) {
        musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePlayEvent());
      } else {
        musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePauseEvent());
      }
    });

    _loopModeSub = player.onLoopModeChange.listen((loopMode) {
      switch (loopMode) {
        case LoopMode.off:
          musicPlayerRepeatModeBloc.add(MusicPlayerRepeatModeOffEvent());
          break;
        case LoopMode.all:
          musicPlayerRepeatModeBloc.add(MusicPlayerRepeatModeAllEvent());
          break;
        case LoopMode.one:
          musicPlayerRepeatModeBloc.add(MusicPlayerRepeatModeOneEvent());
          break;
      }
    });

    _shuffleModeSub = player.onShuffleModeChange.listen((shuffleModeEnabled) {
      if (shuffleModeEnabled) {
        return musicPlayerShuffleModeBloc.add(MusicPlayerShuffleModeAllEvent());
      } else {
        musicPlayerShuffleModeBloc.add(MusicPlayerShuffleModeOffEvent());
      }
    });
  }

  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _currentSequenceSub?.cancel();
    _loopModeSub?.cancel();
    _processingStateSub?.cancel();
    _shuffleModeSub?.cancel();
  }
}
