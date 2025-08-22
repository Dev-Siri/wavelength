import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
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
        controller: _musicPlayerController,
        showVideoProgressIndicator: false,
      ),
    );
  }
}
