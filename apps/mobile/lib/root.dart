import "package:audio_session/audio_session.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/audio/audio_device_service.dart";
import "package:wavelength/audio/player_ui_sync.dart";
import "package:wavelength/bloc/audio_device/audio_device_bloc.dart";
import "package:wavelength/bloc/audio_device/audio_device_event.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_bloc.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class Root extends StatefulWidget {
  final String uri;
  final Widget child;

  const Root({super.key, required this.uri, required this.child});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  final _playerUiSync = PlayerUiSync();

  @override
  void initState() {
    super.initState();
    _playerUiSync.init(context);
    _setupAudioSession();

    final audioDeviceBloc = context.read<AudioDeviceBloc>();

    AudioDeviceService.onDeviceChanged.listen((device) {
      audioDeviceBloc.add(AudioDeviceUpdateEvent(device: device));
    });
  }

  Future<void> _setupAudioSession() async {
    final audioDeviceBloc = context.read<AudioDeviceBloc>();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    audioDeviceBloc.add(
      AudioDeviceUpdateEvent(
        device: await AudioDeviceService.getCurrentDevice(),
      ),
    );
  }

  @override
  void dispose() {
    _playerUiSync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<MusicPlayerTrackBloc, MusicPlayerTrackState>(
        listener: (context, state) {
          if (state is MusicPlayerTrackPlayingNowState) {
            context.read<CoverEffectColorsBloc>().add(
              CoverEffectColorsFetchEvent(
                thumbnail: state.playingNowTrack.thumbnail,
              ),
            );
          }
        },
        child: widget.child,
      ),
    );
  }
}
