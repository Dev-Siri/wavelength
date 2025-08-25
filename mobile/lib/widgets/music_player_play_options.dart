import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";

class MusicPlayerPlayOptions extends StatefulWidget {
  const MusicPlayerPlayOptions({super.key});

  @override
  State<MusicPlayerPlayOptions> createState() => _MusicPlayerPlayOptionsState();
}

class _MusicPlayerPlayOptionsState extends State<MusicPlayerPlayOptions> {
  @override
  Widget build(BuildContext context) {
    final playButtonInnerUi =
        BlocBuilder<MusicPlayerPlaystateBloc, MusicPlayerPlaystateState>(
          builder: (context, state) {
            final isPaused = state is MusicPlayerPlaystatePausedState;

            return Icon(
              isPaused ? LucideIcons.play : LucideIcons.pause,
              color: Colors.black,
              size: 24,
            );
          },
        );

    final previousButtonInnerUi = Icon(
      LucideIcons.skipBack,
      color: Colors.black,
      size: 22,
    );

    final nextButtonInnerUi = Icon(
      LucideIcons.skipForward,
      color: Colors.black,
      size: 22,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<MusicPlayerVolumeBloc, MusicPlayerVolumeState>(
            builder: (context, state) {
              final isMuted = state is MusicPlayerVolumeMutedState;

              return GestureDetector(
                onTap:
                    () => context.read<MusicPlayerVolumeBloc>().add(
                      isMuted
                          ? MusicPlayerVolumeUnmuteEvent()
                          : MusicPlayerVolumeMuteEvent(),
                    ),
                child: Icon(
                  isMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                ),
              );
            },
          ),
          Spacer(),
          if (Platform.isAndroid)
            MaterialButton(
              color: Colors.white.withAlpha(200),
              shape: CircleBorder(side: BorderSide()),
              padding: EdgeInsets.all(14),
              onPressed:
                  () => context.read<MusicPlayerPlaystateBloc>().add(
                    MusicPlayerPlaystateToggleEvent(),
                  ),
              child: previousButtonInnerUi,
            )
          else
            CupertinoButton(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(100),
              padding: EdgeInsets.all(14),
              onPressed:
                  () => context.read<MusicPlayerPlaystateBloc>().add(
                    MusicPlayerPlaystateToggleEvent(),
                  ),
              child: previousButtonInnerUi,
            ),
          SizedBox(width: 15),
          if (Platform.isAndroid)
            MaterialButton(
              color: Colors.white,
              shape: CircleBorder(side: BorderSide()),
              padding: EdgeInsets.all(18),
              onPressed:
                  () => context.read<MusicPlayerPlaystateBloc>().add(
                    MusicPlayerPlaystateToggleEvent(),
                  ),
              child: playButtonInnerUi,
            )
          else
            CupertinoButton(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              padding: EdgeInsets.all(18),
              onPressed:
                  () => context.read<MusicPlayerPlaystateBloc>().add(
                    MusicPlayerPlaystateToggleEvent(),
                  ),
              child: playButtonInnerUi,
            ),
          SizedBox(width: 15),
          if (Platform.isAndroid)
            MaterialButton(
              color: Colors.white.withAlpha(200),
              shape: CircleBorder(side: BorderSide()),
              padding: EdgeInsets.all(14),
              onPressed:
                  () => context.read<MusicPlayerPlaystateBloc>().add(
                    MusicPlayerPlaystateToggleEvent(),
                  ),
              child: nextButtonInnerUi,
            )
          else
            CupertinoButton(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(100),
              padding: EdgeInsets.all(14),
              onPressed:
                  () => context.read<MusicPlayerPlaystateBloc>().add(
                    MusicPlayerPlaystateToggleEvent(),
                  ),
              child: nextButtonInnerUi,
            ),
          Spacer(),
          GestureDetector(
            onTap:
                () => context.read<MusicPlayerRepeatModeBloc>().add(
                  MusicPlayerRepeatModeChangeRepeatModeEvent(),
                ),
            child: BlocBuilder<
              MusicPlayerRepeatModeBloc,
              MusicPlayerRepeatModeState
            >(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child: Opacity(
                    key: ValueKey(state),
                    opacity:
                        state is MusicPlayerRepeatModeRepeatOffState ? 0.5 : 1,
                    child: Icon(
                      state is! MusicPlayerRepeatModeRepeatOneState
                          ? LucideIcons.repeat
                          : LucideIcons.repeat1,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
