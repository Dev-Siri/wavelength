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
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class MusicPlayerInternals {
  final AudioPlayer _player;

  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;

  MusicPlayerInternals() : _player = MusicPlayerSingleton().player;

  void init(BuildContext context) {
    final musicPlayerTrackBloc = context.read<MusicPlayerTrackBloc>();
    final musicPlayerDurationBloc = context.read<MusicPlayerDurationBloc>();
    final musicPlayerPlaystateBloc = context.read<MusicPlayerPlaystateBloc>();
    final musicPlayerRepeatModeBloc = context.read<MusicPlayerRepeatModeBloc>();
    final musicPlayerMusicQueueBloc = context.read<MusicPlayerQueueBloc>();

    _positionSub = _player.positionStream.listen((position) async {
      final musicPlayerDurationState = musicPlayerDurationBloc.state;
      final totalDuration =
          musicPlayerDurationState is MusicPlayerDurationAvailableState
          ? musicPlayerDurationState.totalDuration
          : Duration.zero;

      musicPlayerDurationBloc.add(
        MusicPlayerDurationUpdateDurationEvent(
          newDuration: position,
          totalDuration: totalDuration,
        ),
      );

      final isRunningOnIOS = Platform.isIOS;
      final isDurationAboveZero = totalDuration > Duration.zero;

      if ((isRunningOnIOS && isDurationAboveZero) &&
          position >= totalDuration - const Duration(milliseconds: 10)) {
        if (musicPlayerRepeatModeBloc.state
            is MusicPlayerRepeatModeRepeatAllState) {
          final musicPlayerTrackState = musicPlayerTrackBloc.state;
          final musicPlayerMusicQueueState = musicPlayerMusicQueueBloc.state;

          if (musicPlayerTrackState is! MusicPlayerTrackPlayingNowState) return;

          final currentTrackIndexInQueue = musicPlayerMusicQueueBloc
              .state
              .tracksInQueue
              .indexOf(musicPlayerTrackState.playingNowTrack);

          if (currentTrackIndexInQueue == -1) return;

          final currentTrackPos = currentTrackIndexInQueue + 1;

          musicPlayerTrackBloc.add(
            MusicPlayerTrackLoadEvent(
              queueableMusic:
                  musicPlayerMusicQueueState.tracksInQueue[currentTrackPos ==
                          musicPlayerMusicQueueState.tracksInQueue.length
                      ? 0
                      : currentTrackPos],
            ),
          );
        } else if (musicPlayerRepeatModeBloc.state
            is MusicPlayerRepeatModeRepeatOneState) {
          await _player.seek(Duration.zero);
          _player.play();
        } else {
          _player.pause();
          musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePauseEvent());
        }
      }
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

    _stateSub = _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (musicPlayerRepeatModeBloc.state
            is MusicPlayerRepeatModeRepeatAllState) {
          final musicPlayerTrackState = musicPlayerTrackBloc.state;
          final musicPlayerMusicQueueState = musicPlayerMusicQueueBloc.state;

          if (musicPlayerTrackState is! MusicPlayerTrackPlayingNowState) return;

          final currentTrackIndexInQueue = musicPlayerMusicQueueBloc
              .state
              .tracksInQueue
              .indexOf(musicPlayerTrackState.playingNowTrack);

          if (currentTrackIndexInQueue == -1) return;

          final currentTrackPos = currentTrackIndexInQueue + 1;

          musicPlayerTrackBloc.add(
            MusicPlayerTrackLoadEvent(
              queueableMusic:
                  musicPlayerMusicQueueState.tracksInQueue[currentTrackPos ==
                          musicPlayerMusicQueueState.tracksInQueue.length
                      ? 0
                      : currentTrackPos],
            ),
          );
        } else if (musicPlayerRepeatModeBloc.state
            is MusicPlayerRepeatModeRepeatOneState) {
          await _player.seek(Duration.zero);
          _player.play();
        }
      }

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
