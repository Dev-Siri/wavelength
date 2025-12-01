import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
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

  Future<void> _addTrackToPlaylist(BuildContext context) async {
    void createBottomSheetOpenEvent(WidgetBuilder builder) {
      final appBottomSheetBloc = context.read<AppBottomSheetBloc>();

      appBottomSheetBloc.add(
        AppBottomSheetOpenEvent(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: builder,
        ),
      );
    }

    String duration = track.duration;

    if (duration == "") {
      final durationResponse = await TrackRepo.fetchTrackDuration(
        trackId: track.videoId,
      );

      if (durationResponse is! ApiResponseSuccess<int>) return;

      duration = durationify(Duration(seconds: durationResponse.data));
    }

    createBottomSheetOpenEvent(
      (context) => AddToPlaylistBottomSheet(
        track: Track(
          videoId: track.videoId,
          title: track.title,
          thumbnail: track.thumbnail,
          author: track.author,
          duration: duration,
          isExplicit: track.isExplicit,
        ),
        videoType: VideoType.track,
      ),
    );
  }

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
                  track.title,
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
                  if (track.isExplicit)
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: ExplicitIndicator(),
                    ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2,
                    child: Text(
                      track.author,
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
          CupertinoButton(
            onPressed: () => _addTrackToPlaylist(context),
            child: const Icon(LucideIcons.circlePlus, color: Colors.white),
          ),
        ],
      ),
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _playTrack(context),
        child: innerUi,
      );
    }

    return MaterialButton(
      padding: EdgeInsets.zero,
      onPressed: () => _playTrack(context),
      child: innerUi,
    );
  }
}
