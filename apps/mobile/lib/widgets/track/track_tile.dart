import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/widgets/bottom_sheets/track_options_bottom_sheet.dart";
import "package:wavelength/widgets/track/track_cover.dart";
import "package:wavelength/widgets/track/track_label.dart";
import "package:wavelength/widgets/track/track_like_button.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class TrackTile extends StatelessWidget {
  final MusicContextType? musicContext;
  final List<QueueableMusic> tracks;
  final String? playCount;
  final String? sourceLabel;
  final Track track;

  const TrackTile({
    super.key,
    this.playCount,
    this.musicContext,
    this.tracks = const [],
    required this.track,
    required this.sourceLabel,
  });

  Future<void> _playTrack(BuildContext context) async {
    final trackBloc = context.read<MusicPlayerTrackBloc>();
    final queueableMusic = QueueableMusic(
      videoId: track.videoId,
      title: track.title,
      duration: track.duration,
      isExplicit: track.isExplicit,
      thumbnail: track.thumbnail,
      artists: track.artists,
      videoType: VideoType.track,
      album: track.album,
    );

    trackBloc.add(
      MusicPlayerTrackLoadEvent(
        context: musicContext ?? MusicContextTypeNone(),
        sourceLabel: sourceLabel,
        trackId: queueableMusic.videoId,
        tracks: tracks,
      ),
    );
  }

  void _openPlaylistOptions(BuildContext context) =>
      context.read<AppBottomSheetBloc>().add(
        AppBottomSheetOpenEvent(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) =>
              TrackOptionsBottomSheet(track: track, videoType: VideoType.track),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AmplButton(
      padding: EdgeInsets.zero,
      onPressed: () => _playTrack(context),
      onLongPress: () => _openPlaylistOptions(context),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.all(2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TrackCover(
                      videoId: track.videoId,
                      thumbnail: track.thumbnail,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TrackLabel(
                    title: track.title,
                    artists: track.artists,
                    isExplicit: track.isExplicit,
                    playCount: playCount,
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    durationify(Duration(seconds: track.duration)),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  TrackLikeButton(track: track, videoType: VideoType.track),
                  GestureDetector(
                    onTap: () => _openPlaylistOptions(context),
                    child: Icon(
                      LucideIcons.ellipsis,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
