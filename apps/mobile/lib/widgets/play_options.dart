import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class PlayOptions extends StatelessWidget {
  final String contextId;
  final List<QueueableMusic> songs;

  const PlayOptions({super.key, required this.contextId, required this.songs});

  void _playAll(BuildContext context) {
    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        contextId: contextId,
        queueContext: songs,
        queueableMusic: songs.first,
      ),
    );
  }

  void _shuffle(BuildContext context) {
    final musicPlayer = MusicPlayerSingleton().player;
    musicPlayer.setShuffleModeEnabled(true);
    _playAll(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AmplButton(
          onPressed: () => _playAll(context),
          color: Colors.white,
          child: const Row(
            children: [
              Icon(LucideIcons.play, color: Colors.black, size: 20),
              SizedBox(width: 10),
              Text("Play All", style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        AmplButton(
          onPressed: () => _shuffle(context),
          color: Colors.grey.shade800,
          child: const Row(
            children: [
              Icon(LucideIcons.shuffle, size: 20),
              SizedBox(width: 10),
              Text("Shuffle"),
            ],
          ),
        ),
      ],
    );
  }
}
