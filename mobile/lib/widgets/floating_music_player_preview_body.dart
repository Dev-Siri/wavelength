import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/utils/parse.dart";

class FloatingMusicPlayerPreviewBody extends StatelessWidget {
  final QueueableMusic playingNowTrack;

  const FloatingMusicPlayerPreviewBody({
    super.key,
    required this.playingNowTrack,
  });

  void _playstateButtonHandler(BuildContext context) => context
      .read<MusicPlayerPlaystateBloc>()
      .add(MusicPlayerPlaystateToggleEvent());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: playingNowTrack.thumbnail,
              fit: BoxFit.cover,
              height: 55,
              width: 55,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  playingNowTrack.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  playingNowTrack.author,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<MusicPlayerDurationBloc, MusicPlayerDurationState>(
            builder: (context, state) {
              if (state is! MusicPlayerDurationAvailableState) {
                return Text(
                  "00:00",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                );
              }

              return Text(
                "-${durationify(state.totalDuration - state.currentDuration)}",
              );
            },
          ),
          BlocBuilder<MusicPlayerPlaystateBloc, MusicPlayerPlaystateState>(
            builder: (context, state) {
              final isMusicPlaying = state is MusicPlayerPlaystatePlayingState;
              final playstateButtonInnerUi = Icon(
                isMusicPlaying ? LucideIcons.pause : LucideIcons.play,
                color: Colors.white,
                semanticLabel: isMusicPlaying ? "Pause" : "Play",
              );

              if (Platform.isAndroid) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _playstateButtonHandler(context),
                  icon: playstateButtonInnerUi,
                );
              }

              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _playstateButtonHandler(context),
                child: playstateButtonInnerUi,
              );
            },
          ),
        ],
      ),
    );
  }
}
