import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";

class MusicPlayerInternals {
  final AudioPlayer _player;

  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _currentIndexSub;
  StreamSubscription? _durationSub;

  MusicPlayerInternals() : _player = MusicPlayerSingleton().player;

  void init(BuildContext context) {
    final musicPlayerQueueBloc = context.read<MusicPlayerQueueBloc>();
    final musicPlayerDurationBloc = context.read<MusicPlayerDurationBloc>();
    final musicPlayerPlaystateBloc = context.read<MusicPlayerPlaystateBloc>();
    final musicPlayerTrackBloc = context.read<MusicPlayerTrackBloc>();

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

    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index == null) return;

      final currentSource = _player.sequence[index];
      final tag = currentSource.tag;

      if (tag is! MediaItem) return;

      final playingTrackIndex = musicPlayerQueueBloc.state.tracksInQueue
          .indexWhere((track) => track.videoId == tag.id);

      if (playingTrackIndex == -1) return;

      musicPlayerTrackBloc.add(
        MusicPlayerTrackAutoLoadEvent(
          queueableMusic:
              musicPlayerQueueBloc.state.tracksInQueue[playingTrackIndex],
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
            totalDuration: duration,
          ),
        );
      }
    });

    _stateSub = _player.playerStateStream.listen((state) async {
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
    _currentIndexSub?.cancel();
    _durationSub?.cancel();
  }
}
