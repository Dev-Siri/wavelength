import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/widgets/add_to_playlist_bottom_sheet.dart";

class TopTrackResult extends StatelessWidget {
  final Track track;

  const TopTrackResult({super.key, required this.track});

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
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(imageUrl: track.thumbnail),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decodeHtmlSpecialChars(track.title),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  track.author,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _playTrack(context),
                      child:
                          BlocBuilder<
                            MusicPlayerTrackBloc,
                            MusicPlayerTrackState
                          >(
                            builder: (context, state) {
                              if (state is MusicPlayerTrackPlayingNowState &&
                                  state.playingNowTrack.videoId ==
                                      track.videoId) {
                                return MiniMusicVisualizer(
                                  color: Colors.white,
                                  animate: true,
                                  width: 4,
                                  height: 15,
                                );
                              }

                              return Icon(
                                LucideIcons.play,
                                color: Colors.white,
                              );
                            },
                          ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
