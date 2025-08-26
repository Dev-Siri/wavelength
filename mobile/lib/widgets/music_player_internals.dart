import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:youtube_player_flutter/youtube_player_flutter.dart";

class MusicPlayerInternals extends StatefulWidget {
  const MusicPlayerInternals({super.key});

  @override
  State<MusicPlayerInternals> createState() => _MusicPlayerInternalsState();
}

class _MusicPlayerInternalsState extends State<MusicPlayerInternals> {
  late YoutubePlayerController _musicPlayerController;

  @override
  void initState() {
    _musicPlayerController = MusicPlayerSingleton().controller;

    _musicPlayerController.addListener(_playerStateChangeListener);
    _musicPlayerController.addListener(_playerProgressListener);

    super.initState();
  }

  void _playerStateChangeListener() {
    if (_musicPlayerController.value.isPlaying) {
      return context.read<MusicPlayerPlaystateBloc>().add(
        MusicPlayerPlaystatePlayEvent(),
      );
    }

    context.read<MusicPlayerPlaystateBloc>().add(
      MusicPlayerPlaystatePauseEvent(),
    );
  }

  void _playerProgressListener() {
    final position = _musicPlayerController.value.position;
    final duration = _musicPlayerController.value.metaData.duration;

    context.read<MusicPlayerDurationBloc>().add(
      MusicPlayerDurationUpdateDurationEvent(
        totalDuration: duration,
        newDuration: position,
      ),
    );
  }

  void _handlePlayerPlayingEnd(YoutubeMetaData _) {
    final playerRepeatModeState =
        context.read<MusicPlayerRepeatModeBloc>().state;

    switch (playerRepeatModeState) {
      case MusicPlayerRepeatModeRepeatAllState _:
        final musicQueue = context.read<MusicPlayerQueueBloc>().state;
        final currentTrackState = context.read<MusicPlayerTrackBloc>().state;

        if (currentTrackState is! MusicPlayerTrackPlayingNowState) break;

        final currentTrackIndexInQueue = musicQueue.tracksInQueue.indexOf(
          currentTrackState.playingNowTrack,
        );

        if (currentTrackIndexInQueue == -1) break;

        final currentTrackPos = currentTrackIndexInQueue + 1;

        context.read<MusicPlayerTrackBloc>().add(
          MusicPlayerTrackLoadEvent(
            queueableMusic:
                musicQueue.tracksInQueue[currentTrackPos ==
                        musicQueue.tracksInQueue.length
                    ? 0
                    : currentTrackPos],
          ),
        );

        break;
      case MusicPlayerRepeatModeRepeatOneState _:
        _musicPlayerController.seekTo(Duration(seconds: 0));
    }
  }

  @override
  void dispose() {
    _musicPlayerController.removeListener(_playerStateChangeListener);
    _musicPlayerController.removeListener(_playerProgressListener);
    _musicPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: false,
      child: YoutubePlayer(
        // This is totally a hack to get the player invisible while still retaining playback from the iframe.
        // Changing opacity / Offstage(offstage: true) causes the player to stop due to no visibility.
        width: 1,
        controller: _musicPlayerController,
        showVideoProgressIndicator: false,
        onEnded: _handlePlayerPlayingEnd,
      ),
    );
  }
}
