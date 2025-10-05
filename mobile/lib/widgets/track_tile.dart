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
import "package:wavelength/widgets/add_to_playlist_bottom_sheet.dart";
import "package:wavelength/widgets/explicit_indicator.dart";

class TrackTile extends StatelessWidget {
  final Track track;

  const TrackTile({super.key, required this.track});

  void _playTrack(BuildContext context) {
    final queueableMusic = QueueableMusic(
      videoId: track.videoId,
      title: track.title,
      thumbnail: track.thumbnail,
      duration: parseToDuration(track.duration),
      author: track.author,
      videoType: VideoType.track,
    );

    context.read<MusicPlayerQueueBloc>().add(
      MusicPlayerQueueAddToQueueEvent(queueableMusic: queueableMusic),
    );
    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(queueableMusic: queueableMusic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            onPressed: () => _playTrack(context),
            padding: EdgeInsets.zero,
            sizeStyle: CupertinoButtonSize.small,
            child: Row(
              children: [
                BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
                  builder: (context, state) {
                    final isThisTrackPlaying =
                        state is MusicPlayerTrackPlayingNowState &&
                        state.playingNowTrack.videoId == track.videoId;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: isThisTrackPlaying ? 0.2 : 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: track.thumbnail,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isThisTrackPlaying)
                          MiniMusicVisualizer(
                            color: Colors.white,
                            animate: true,
                            width: 4,
                            height: 15,
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        track.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        if (track.isExplicit)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ExplicitIndicator(),
                          ),
                        Text(
                          track.author,
                          style: TextStyle(
                            color: Colors.grey,
                            height: 1,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: () => context.read<AppBottomSheetBloc>().add(
              AppBottomSheetOpenEvent(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (context) => AddToPlaylistBottomSheet(
                  track: Track(
                    videoId: track.videoId,
                    title: track.title,
                    thumbnail: track.thumbnail,
                    author: track.author,
                    duration: track.duration,
                    isExplicit: track.isExplicit,
                  ),
                  videoType: VideoType.track,
                ),
              ),
            ),
            child: Icon(LucideIcons.circlePlus, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
