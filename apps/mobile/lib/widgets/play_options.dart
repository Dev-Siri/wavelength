import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:glass/glass.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class PlayOptions extends StatelessWidget {
  final MusicContextType musicContext;
  final List<QueueableMusic> songs;
  final String? sourceLabel;

  final bool glass;

  const PlayOptions({
    super.key,
    required this.musicContext,
    required this.songs,
    required this.sourceLabel,
    this.glass = false,
  });

  void _playAll(BuildContext context) {
    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        sourceLabel: sourceLabel,
        context: musicContext,
        trackId: songs[0].videoId,
        tracks: songs,
      ),
    );
  }

  void _shuffle(BuildContext context) {
    context.read<WavelengthAudioHandler>().setShuffleEnabled(true);
    _playAll(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AmplButton(
          onPressed: () => _playAll(context),
          color: glass ? Colors.transparent : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              SvgPicture(
                const AssetBytesLoader("assets/vectors/icons/play.svg.vec"),
                height: 25,
                width: 25,
                colorFilter: glass
                    ? null
                    : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Text(
                "Play",
                style: TextStyle(color: glass ? Colors.white : Colors.black),
              ),
            ],
          ),
        ).asGlass(
          enabled: glass,
          frosted: true,
          blurX: 20,
          blurY: 20,
          clipBorderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(width: 10),
        AmplButton(
          onPressed: () => _shuffle(context),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: glass ? Colors.transparent : Colors.grey.shade800,
          child: const Row(
            children: [
              Icon(LucideIcons.shuffle, size: 20),
              SizedBox(width: 10),
              Text("Shuffle"),
            ],
          ),
        ).asGlass(
          enabled: glass,
          frosted: true,
          blurX: 20,
          blurY: 20,
          clipBorderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
