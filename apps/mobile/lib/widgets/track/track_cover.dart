import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class TrackCover extends StatelessWidget {
  final String videoId;
  final String thumbnail;

  const TrackCover({super.key, required this.videoId, required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      builder: (context, state) {
        final isThisTrackPlaying =
            state is MusicPlayerTrackPlayingNowState &&
            state.playingNowTrack.videoId == videoId;

        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: isThisTrackPlaying ? 0.2 : 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: thumbnail,
                  fit: BoxFit.cover,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            if (isThisTrackPlaying)
              const MiniMusicVisualizer(
                color: Colors.white,
                animate: true,
                width: 4,
                height: 15,
              ),
          ],
        );
      },
    );
  }
}
