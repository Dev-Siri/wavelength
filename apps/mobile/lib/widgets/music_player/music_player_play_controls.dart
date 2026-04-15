import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class MusicPlayerControls extends StatelessWidget {
  const MusicPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AmplIconButton(
          onPressed: () =>
              context.read<WavelengthAudioHandler>().skipToPrevious(),
          icon: const SvgPicture(
            AssetBytesLoader("assets/vectors/icons/skip-back.svg.vec"),
            height: 40,
            width: 40,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AmplIconButton(
            onPressed: () => context.read<MusicPlayerPlaystateBloc>().add(
              MusicPlayerPlaystateToggleEvent(),
            ),
            icon:
                BlocBuilder<
                  MusicPlayerPlaystateBloc,
                  MusicPlayerPlaystateState
                >(
                  builder: (context, state) {
                    final isPaused = state is MusicPlayerPlaystatePausedState;

                    return SvgPicture(
                      AssetBytesLoader(
                        isPaused
                            ? "assets/vectors/icons/play.svg.vec"
                            : "assets/vectors/icons/pause.svg.vec",
                      ),
                      height: 60,
                      width: 60,
                    );
                  },
                ),
          ),
        ),
        AmplIconButton(
          onPressed: () => context.read<WavelengthAudioHandler>().skipToNext(),
          icon: const SvgPicture(
            AssetBytesLoader("assets/vectors/icons/skip-forward.svg.vec"),
            height: 40,
            width: 40,
          ),
        ),
      ],
    );
  }
}
