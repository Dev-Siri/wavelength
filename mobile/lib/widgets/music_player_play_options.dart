import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/audio/background_audio_source.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";

class MusicPlayerPlayOptions extends StatelessWidget {
  const MusicPlayerPlayOptions({super.key});

  Future<void> _playNext(BuildContext context) async {
    final trackBloc = context.read<MusicPlayerTrackBloc>();
    final player = MusicPlayerSingleton().player;

    final sourceIndex = player.nextIndex ?? 0;
    await player.seekToNext();

    final source = player.audioSources[sourceIndex];
    if (source is! BackgroundAudioSource) return;

    final tag = source.tag;
    if (tag is! MediaItem) return;

    trackBloc.add(
      MusicPlayerTrackAutoLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: tag.id,
          title: tag.title,
          thumbnail: tag.artUri?.toString() ?? "",
          author: tag.artist ?? "",
          videoType: tag.extras?["videoType]"] == "track"
              ? VideoType.track
              : VideoType.uvideo,
        ),
      ),
    );
  }

  Future<void> _playPrevious(BuildContext context) async {
    final trackBloc = context.read<MusicPlayerTrackBloc>();
    final player = MusicPlayerSingleton().player;

    final sourceIndex = player.previousIndex ?? 0;
    await player.seekToPrevious();

    final source = player.audioSources[sourceIndex];
    if (source is! BackgroundAudioSource) return;

    final tag = source.tag;
    if (tag is! MediaItem) return;

    trackBloc.add(
      MusicPlayerTrackAutoLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: tag.id,
          title: tag.title,
          thumbnail: tag.artUri?.toString() ?? "",
          author: tag.artist ?? "",
          videoType: tag.extras?["videoType]"] == "track"
              ? VideoType.track
              : VideoType.uvideo,
        ),
      ),
    );
  }

  Future<void> _changeRepeatMode() async {
    final player = MusicPlayerSingleton().player;

    switch (player.loopMode) {
      case LoopMode.off:
        await player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await player.setLoopMode(LoopMode.off);
        break;
    }
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
              onPressed: () => _playPrevious(context),
              child: previousButtonInnerUi,
            )
          else
            CupertinoButton(
              borderRadius: BorderRadius.circular(100),
              padding: const EdgeInsets.all(14),
              onPressed: () => _playPrevious(context),
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
              onPressed: () => _playNext(context),
              child: nextButtonInnerUi,
            )
          else
            CupertinoButton(
              borderRadius: BorderRadius.circular(100),
              padding: const EdgeInsets.all(14),
              onPressed: () => _playNext(context),
              child: nextButtonInnerUi,
            ),
          const Spacer(),
          GestureDetector(
            onTap: _changeRepeatMode,
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
