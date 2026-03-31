import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_state.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_event.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_state.dart";
import "package:wavelength/screens/playing_now.dart";
import "package:wavelength/widgets/music_queue/music_queue_display.dart";

class MusicPlayerPlaybackOptions extends StatelessWidget {
  final void Function() switchPresenters;
  final PlayingNowPresenter presentedScreen;

  const MusicPlayerPlaybackOptions({
    super.key,
    required this.presentedScreen,
    required this.switchPresenters,
  });

  @override
  Widget build(BuildContext context) {
    final switcherText = presentedScreen == PlayingNowPresenter.preview
        ? "Lyrics"
        : "Playing Now";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
        GestureDetector(
          onTap: () => context.read<WavelengthAudioHandler>().cycleLoopMode(),
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
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
        ),
        GestureDetector(
          onTap: () =>
              context.read<WavelengthAudioHandler>().toggleShuffleEnabled(),
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
                      opacity: state is MusicPlayerShuffleModeShuffleOffState
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
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            builder: (_) => const MusicQueueDisplay(),
          ),
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
                      opacity: state is MusicPlayerShuffleModeShuffleOffState
                          ? 0.5
                          : 1,
                      child: const Icon(
                        LucideIcons.columns3,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
        ),
        GestureDetector(
          onTap: switchPresenters,
          child: Icon(
            presentedScreen == PlayingNowPresenter.preview
                ? LucideIcons.micVocal
                : LucideIcons.squarePlay,
            size: 20,
            semanticLabel: switcherText,
          ),
        ),
      ],
    );
  }
}
