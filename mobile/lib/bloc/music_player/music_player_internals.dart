import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class MusicPlayerInternals {
  final AudioPlayer _player;

  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _currentIndexSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _loopModeSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _processingStateSub;

  MusicPlayerInternals() : _player = MusicPlayerSingleton().player;

  Future<void> _handlePlaybackEnd() async {
    final currentIndex = _player.currentIndex ?? 0;

    switch (_player.loopMode) {
      case LoopMode.one:
        await _player.seek(Duration.zero, index: currentIndex);
        await _player.play();
        break;
      case LoopMode.all:
        if (_player.hasNext) {
          await _player.seekToNext();
        } else {
          await _player.seek(Duration.zero, index: 0);
        }
        await _player.play();
        break;
      case LoopMode.off:
        if (_player.hasNext) {
          await _player.seekToNext();
          await _player.play();
        }
        break;
    }
  }

  void init(BuildContext context) {
    final musicPlayerDurationBloc = context.read<MusicPlayerDurationBloc>();
    final musicPlayerPlaystateBloc = context.read<MusicPlayerPlaystateBloc>();
    final musicPlayerTrackBloc = context.read<MusicPlayerTrackBloc>();
    final musicPlayerRepeatModeBloc = context.read<MusicPlayerRepeatModeBloc>();

    _errorSub = _player.errorStream.listen((error) {
      DiagnosticsRepo.reportError(
        error: error.toString(),
        source: "(listener) just_audio: AudioPlayer.errorStream",
      );
    });

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
    });

    _currentIndexSub = _player.sequenceStateStream.listen((state) {
      final source = state.currentSource;

      if (source == null) return;

      final tag = source.tag;
      if (tag is! MediaItem) return;

      musicPlayerTrackBloc.add(
        MusicPlayerTrackAutoLoadEvent(
          queueableMusic: QueueableMusic(
            videoId: tag.id,
            title: tag.title,
            thumbnail: tag.artUri?.toString() ?? "",
            author: tag.artist ?? "",
            videoType: tag.extras?["videoType"] == "track"
                ? VideoType.track
                : VideoType.uvideo,
          ),
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
            totalDuration: duration,
          ),
        );
      }
    });

    _stateSub = _player.playerStateStream.listen((state) async {
      if (state.playing) {
        musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePlayEvent());
      } else {
        musicPlayerPlaystateBloc.add(MusicPlayerPlaystatePauseEvent());
      }
    });

    _loopModeSub = _player.loopModeStream.listen((loopMode) {
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

    _processingStateSub = _player.processingStateStream
        .where(
          (s) => s == ProcessingState.idle || s == ProcessingState.completed,
        )
        .listen((_) async {
          if (musicPlayerTrackBloc.state is MusicPlayerTrackPlayingNowState) {
            await _handlePlaybackEnd();
          }
        });
  }

  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _currentIndexSub?.cancel();
    _durationSub?.cancel();
    _errorSub?.cancel();
    _loopModeSub?.cancel();
    _processingStateSub?.cancel();
  }
}
