import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_event.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";

class MusicPlayerPlayOptions extends StatelessWidget {
  const MusicPlayerPlayOptions({super.key});

  void _playPreviousTrack(BuildContext context) {
    final musicPlayerTrackBloc = context.read<MusicPlayerTrackBloc>();
    final musicPlayerMusicQueueBloc = context.read<MusicPlayerQueueBloc>();

    final musicPlayerTrackState = musicPlayerTrackBloc.state;
    final musicPlayerMusicQueueState = musicPlayerMusicQueueBloc.state;

    if (musicPlayerTrackState is! MusicPlayerTrackPlayingNowState) return;

    final currentTrackIndexInQueue = musicPlayerMusicQueueBloc
        .state
        .tracksInQueue
        .indexOf(musicPlayerTrackState.playingNowTrack);

    if (currentTrackIndexInQueue == -1 ||
        musicPlayerMusicQueueState.tracksInQueue.isEmpty) {
      return;
    }

    final prevTrackPos = currentTrackIndexInQueue - 1 < 0
        ? musicPlayerMusicQueueState.tracksInQueue.length - 1
        : currentTrackIndexInQueue - 1;

    musicPlayerTrackBloc.add(
      MusicPlayerTrackLoadEvent(
        queueableMusic: musicPlayerMusicQueueState.tracksInQueue[prevTrackPos],
      ),
    );
  }

  void _playNextTrack(BuildContext context) {
    final musicPlayerTrackBloc = context.read<MusicPlayerTrackBloc>();
    final musicPlayerMusicQueueBloc = context.read<MusicPlayerQueueBloc>();

    final musicPlayerTrackState = musicPlayerTrackBloc.state;
    final musicPlayerMusicQueueState = musicPlayerMusicQueueBloc.state;

    if (musicPlayerTrackState is! MusicPlayerTrackPlayingNowState) return;

    final currentTrackIndexInQueue = musicPlayerMusicQueueBloc
        .state
        .tracksInQueue
        .indexOf(musicPlayerTrackState.playingNowTrack);

    if (currentTrackIndexInQueue == -1 ||
        musicPlayerMusicQueueState.tracksInQueue.isEmpty) {
      return;
    }

    final nextTrackPos =
        currentTrackIndexInQueue + 1 >=
            musicPlayerMusicQueueState.tracksInQueue.length
        ? 0
        : currentTrackIndexInQueue + 1;

    musicPlayerTrackBloc.add(
      MusicPlayerTrackLoadEvent(
        queueableMusic: musicPlayerMusicQueueState.tracksInQueue[nextTrackPos],
      ),
    );
  }

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

    final previousButtonInnerUi = const Icon(
      LucideIcons.skipBack,
      color: Colors.white,
      size: 22,
    );

    final nextButtonInnerUi = const Icon(
      LucideIcons.skipForward,
      color: Colors.white,
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
                onTap: () => context.read<MusicPlayerVolumeBloc>().add(
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
          const Spacer(),
          if (Platform.isAndroid)
            MaterialButton(
              minWidth: 0,
              height: 0,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              padding: const EdgeInsets.all(14),
              onPressed: () => _playPreviousTrack(context),
              child: previousButtonInnerUi,
            )
          else
            CupertinoButton(
              borderRadius: BorderRadius.circular(100),
              padding: const EdgeInsets.all(14),
              onPressed: () => _playPreviousTrack(context),
              child: previousButtonInnerUi,
            ),
          const SizedBox(width: 15),
          if (Platform.isAndroid)
            MaterialButton(
              minWidth: 0,
              height: 0,
              color: Colors.white,
              shape: const CircleBorder(side: BorderSide()),
              padding: const EdgeInsets.all(18),
              onPressed: () => context.read<MusicPlayerPlaystateBloc>().add(
                MusicPlayerPlaystateToggleEvent(),
              ),
              child: playButtonInnerUi,
            )
          else
            CupertinoButton(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              padding: const EdgeInsets.all(18),
              onPressed: () => context.read<MusicPlayerPlaystateBloc>().add(
                MusicPlayerPlaystateToggleEvent(),
              ),
              child: playButtonInnerUi,
            ),
          const SizedBox(width: 15),
          if (Platform.isAndroid)
            MaterialButton(
              minWidth: 0,
              height: 0,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              padding: const EdgeInsets.all(14),
              onPressed: () => _playNextTrack(context),
              child: nextButtonInnerUi,
            )
          else
            CupertinoButton(
              borderRadius: BorderRadius.circular(100),
              padding: const EdgeInsets.all(14),
              onPressed: () => _playNextTrack(context),
              child: nextButtonInnerUi,
            ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.read<MusicPlayerRepeatModeBloc>().add(
              MusicPlayerRepeatModeChangeRepeatModeEvent(),
            ),
            child:
                BlocBuilder<
                  MusicPlayerRepeatModeBloc,
                  MusicPlayerRepeatModeState
                >(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Opacity(
                        key: ValueKey(state),
                        opacity: state is MusicPlayerRepeatModeRepeatOffState
                            ? 0.5
                            : 1,
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
