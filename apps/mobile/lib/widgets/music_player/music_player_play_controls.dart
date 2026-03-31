import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class MusicPlayerControls extends StatelessWidget {
  const MusicPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AmplButton(
            minWidth: 0,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.all(14),
            onPressed: () =>
                context.read<WavelengthAudioHandler>().skipToPrevious(),
            child: const Icon(
              LucideIcons.skipBack,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 25),
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
          const SizedBox(width: 25),
          AmplButton(
            minWidth: 0,
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(100),
            onPressed: () =>
                context.read<WavelengthAudioHandler>().skipToNext(),
            child: const Icon(
              LucideIcons.skipForward,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
