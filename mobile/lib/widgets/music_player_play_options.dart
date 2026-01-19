import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/audio/background_audio_source.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

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

    final embedded = tag.extras?["embedded"];
    if (embedded == null) return;

    final VideoType videoType = tag.extras?["videoType"] ?? VideoType.track;

    trackBloc.add(
      MusicPlayerTrackAutoLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: tag.id,
          title: tag.title,
          thumbnail: tag.artUri?.toString() ?? "",
          artists: embedded["artists"] as List<EmbeddedArtist>,
          album: embedded["album"] as EmbeddedAlbum,
          videoType: videoType,
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

    final embedded = tag.extras?["embedded"];
    if (embedded == null) return;

    final VideoType videoType = tag.extras?["videoType"] ?? VideoType.track;

    trackBloc.add(
      MusicPlayerTrackAutoLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: tag.id,
          title: tag.title,
          thumbnail: tag.artUri?.toString() ?? "",
          artists: embedded["artists"] as List<EmbeddedArtist>,
          album: embedded["album"] as EmbeddedAlbum,
          videoType: videoType,
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

  Future<void> _toggleShuffleMode() async {
    final player = MusicPlayerSingleton().player;
    await player.setShuffleModeEnabled(!player.shuffleModeEnabled);
  }

  @override
  Widget build(BuildContext context) {
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
                  size: 20,
                ),
              );
            },
          ),
          const Spacer(),
          AmplButton(
            minWidth: 0,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.all(14),
            onPressed: () => _playPrevious(context),
            child: const Icon(
              LucideIcons.skipBack,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          AmplButton(
            minWidth: 0,
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.all(18),
            onPressed: () => context.read<MusicPlayerPlaystateBloc>().add(
              MusicPlayerPlaystateToggleEvent(),
            ),
            child:
                BlocBuilder<
                  MusicPlayerPlaystateBloc,
                  MusicPlayerPlaystateState
                >(
                  builder: (context, state) {
                    final isPaused = state is MusicPlayerPlaystatePausedState;

                    return Icon(
                      isPaused ? LucideIcons.play : LucideIcons.pause,
                      color: Colors.black,
                      size: 24,
                    );
                  },
                ),
          ),
          const SizedBox(width: 15),
          AmplButton(
            minWidth: 0,
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(100),
            onPressed: () => _playNext(context),
            child: const Icon(
              LucideIcons.skipForward,
              color: Colors.white,
              size: 22,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleShuffleMode,
                child:
                    BlocBuilder<
                      MusicPlayerShuffleModeBloc,
                      MusicPlayerShuffleModeState
                    >(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Opacity(
                            key: ValueKey(state),
                            opacity:
                                state is MusicPlayerShuffleModeShuffleOffState
                                ? 0.5
                                : 1,
                            child: const Icon(
                              LucideIcons.shuffle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
              ),
              const SizedBox(width: 20),
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
                            opacity:
                                state is MusicPlayerRepeatModeRepeatOffState
                                ? 0.5
                                : 1,
                            child: Icon(
                              state is! MusicPlayerRepeatModeRepeatOneState
                                  ? LucideIcons.repeat
                                  : LucideIcons.repeat1,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
