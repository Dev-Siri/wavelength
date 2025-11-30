import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/models/video.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/add_to_playlist_bottom_sheet.dart";

class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({super.key, required this.video});

  Future<void> _playYouTubeVideo(BuildContext context) async {
    final musicTrackBloc = context.read<MusicPlayerTrackBloc>();
    final durationResponse = await TrackRepo.fetchTrackDuration(
      trackId: video.videoId,
    );

    if (durationResponse is ApiResponseSuccess<int>) {
      musicTrackBloc.add(
        MusicPlayerTrackLoadEvent(
          queueableMusic: QueueableMusic(
            videoId: video.videoId,
            title: video.title,
            thumbnail: getTrackThumbnail(video.videoId),
            author: video.author,
            videoType: VideoType.uvideo,
          ),
        ),
      );
    }
  }

  Future<void> _showPlaylistAdditionDialog(BuildContext context) async {
    final callBottomSheet = generateBottomSheetFn(context);
    final durationResponse = await TrackRepo.fetchTrackDuration(
      trackId: video.videoId,
    );

    if (durationResponse is ApiResponseSuccess<int>) {
      callBottomSheet(durationResponse.data);
    }
  }

  // To avoid using context across async gaps, I guess you can call it a hack.
  void Function(int) generateBottomSheetFn(BuildContext context) {
    final bottomSheetBloc = context.read<AppBottomSheetBloc>();

    return (duration) {
      bottomSheetBloc.add(
        AppBottomSheetOpenEvent(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => AddToPlaylistBottomSheet(
            track: Track(
              videoId: video.videoId,
              title: video.title,
              thumbnail: getTrackThumbnail(video.videoId),
              author: video.author,
              duration: durationify(Duration(seconds: duration)),
              isExplicit: false,
            ),
            videoType: VideoType.track,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = CachedNetworkImage(
      imageUrl: video.thumbnail,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Platform.isAndroid
                  ? MaterialButton(
                      onPressed: () => _playYouTubeVideo(context),
                      padding: EdgeInsets.zero,
                      child: thumbnail,
                    )
                  : CupertinoButton(
                      onPressed: () => _playYouTubeVideo(context),
                      padding: EdgeInsets.zero,
                      child: thumbnail,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  children: [
                    TextSpan(
                      text: video.title.length > 50
                          ? "${video.title.substring(0, 50)}..."
                          : video.title,
                    ),
                    TextSpan(
                      text: " - ${video.author}",
                      style: const TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: () => _showPlaylistAdditionDialog(context),
                      child: const Icon(
                        LucideIcons.circlePlus,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        minWidth: 20,
                        onPressed: () => _showPlaylistAdditionDialog(context),
                        child: const Icon(LucideIcons.circlePlus),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
