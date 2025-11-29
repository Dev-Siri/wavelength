import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/explicit_indicator.dart";
import "package:wavelength/widgets/playlist_track_tile_options_bottom_sheet.dart";

class PlaylistTrackTile extends StatelessWidget {
  final List<PlaylistTrack> allPlaylistTracks;
  final PlaylistTrack playlistTrack;

  const PlaylistTrackTile({
    super.key,
    required this.playlistTrack,
    required this.allPlaylistTracks,
  });

  void _playSong(BuildContext context) {
    final queueableMusic = QueueableMusic(
      videoId: playlistTrack.videoId,
      title: playlistTrack.title,
      thumbnail: getTrackThumbnail(playlistTrack.videoId),
      duration: parseToDuration(playlistTrack.duration),
      author: playlistTrack.author,
      videoType: playlistTrack.videoType,
    );

    context.read<MusicPlayerQueueBloc>().add(
      MusicPlayerReplaceQueueEvent(
        newQueue: allPlaylistTracks
            .map(
              (track) => QueueableMusic(
                videoId: track.videoId,
                title: track.title,
                thumbnail: getTrackThumbnail(track.videoId),
                duration: parseToDuration(track.duration),
                author: track.author,
                videoType: track.videoType,
              ),
            )
            .toList(),
      ),
    );

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(queueableMusic: queueableMusic),
    );
  }

  void _showPlaylistTrackOptions(BuildContext context) =>
      context.read<AppBottomSheetBloc>().add(
        AppBottomSheetOpenEvent(
          context: context,
          builder: (_) => PlaylistTrackTileOptionsBottomSheet(
            playlistId: playlistTrack.playlistId,
            videoType: playlistTrack.videoType,
            track: Track(
              videoId: playlistTrack.videoId,
              title: playlistTrack.title,
              thumbnail: playlistTrack.thumbnail,
              author: playlistTrack.author,
              duration: playlistTrack.duration,
              isExplicit: playlistTrack.isExplicit,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final innerUi = Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
            builder: (context, state) {
              final isThisTrackPlaying =
                  state is MusicPlayerTrackPlayingNowState &&
                  state.playingNowTrack.videoId == playlistTrack.videoId;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isThisTrackPlaying ? 0.2 : 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: playlistTrack.thumbnail,
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
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: (MediaQuery.sizeOf(context).width / 1.4) - 50,
                child: Text(
                  playlistTrack.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  if (playlistTrack.isExplicit)
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: ExplicitIndicator(),
                    ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2,
                    child: Text(
                      playlistTrack.author,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            playlistTrack.duration.toString(),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => _showPlaylistTrackOptions(context),
              child: const Icon(LucideIcons.ellipsis, color: Colors.grey),
            ),
          ),
        ],
      ),
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _playSong(context),
        child: innerUi,
      );
    }

    return MaterialButton(
      padding: EdgeInsets.zero,
      onPressed: () => _playSong(context),
      child: innerUi,
    );
  }
}
