import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/track/track_cover.dart";
import "package:wavelength/widgets/track/track_label.dart";
import "package:wavelength/widgets/track/track_like_button.dart";
import "package:wavelength/widgets/bottom_sheets/playlist_track_extended_options.dart";
import "package:wavelength/widgets/bottom_sheets/track_options_bottom_sheet.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class PlaylistTrackTile extends StatefulWidget {
  final List<PlaylistTrack> allPlaylistTracks;
  final PlaylistTrack playlistTrack;
  final String playlistTitle;

  const PlaylistTrackTile({
    super.key,
    required this.playlistTrack,
    required this.allPlaylistTracks,
    required this.playlistTitle,
  });

  @override
  State<PlaylistTrackTile> createState() => _PlaylistTrackTileState();
}

class _PlaylistTrackTileState extends State<PlaylistTrackTile> {
  bool _isTrackDownloaded = false;

  @override
  void initState() {
    super.initState();
    _fetchTrackDownloadStatus();
  }

  Future<void> _fetchTrackDownloadStatus() async {
    if (!mounted) return;
    final box = await Hive.openBox(hiveStreamsKey);
    final exists = box.containsKey(widget.playlistTrack.videoId);

    if (mounted) setState(() => _isTrackDownloaded = exists);
  }

  void _playSong(BuildContext context) {
    final queue = widget.allPlaylistTracks
        .map(
          (track) => QueueableMusic(
            videoId: track.videoId,
            duration: track.duration,
            title: track.title,
            isExplicit: track.isExplicit,
            thumbnail: getUpscaledTrackThumbnail(track.thumbnail),
            artists: track.artists,
            videoType: track.videoType,
            album: track.album,
          ),
        )
        .toList();

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        trackId: widget.playlistTrack.videoId,
        sourceLabel: widget.playlistTitle,
        context: MusicContextTypePlaylist(
          playlistId: widget.playlistTrack.playlistId,
        ),
        tracks: queue,
      ),
    );
  }

  void _showPlaylistTrackOptions(BuildContext context) {
    final track = Track(
      videoId: widget.playlistTrack.videoId,
      title: widget.playlistTrack.title,
      thumbnail: widget.playlistTrack.thumbnail,
      artists: widget.playlistTrack.artists,
      duration: widget.playlistTrack.duration,
      isExplicit: widget.playlistTrack.isExplicit,
      album: widget.playlistTrack.album,
    );

    context.read<AppBottomSheetBloc>().add(
      AppBottomSheetOpenEvent(
        context: context,
        builder: (_) => TrackOptionsBottomSheet(
          extendedList: PlaylistTrackExtendedOptions(
            playlistId: widget.playlistTrack.playlistId,
            track: track,
            videoType: widget.playlistTrack.videoType,
          ),
          videoType: widget.playlistTrack.videoType,
          track: track,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmplButton(
      padding: EdgeInsets.zero,
      onPressed: () => _playSong(context),
      onLongPress: () => _showPlaylistTrackOptions(context),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TrackCover(
                      videoId: widget.playlistTrack.videoId,
                      thumbnail: widget.playlistTrack.thumbnail,
                    ),
                  ),
                  TrackLabel(
                    title: widget.playlistTrack.title,
                    artists: widget.playlistTrack.artists,
                    isExplicit: widget.playlistTrack.isExplicit,
                    showDownloadedBadge: _isTrackDownloaded,
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
                    durationify(
                      Duration(seconds: widget.playlistTrack.duration),
                    ),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  TrackLikeButton(
                    track: Track(
                      videoId: widget.playlistTrack.videoId,
                      title: widget.playlistTrack.title,
                      thumbnail: widget.playlistTrack.thumbnail,
                      artists: widget.playlistTrack.artists,
                      duration: widget.playlistTrack.duration,
                      isExplicit: widget.playlistTrack.isExplicit,
                      album: widget.playlistTrack.album,
                    ),
                    videoType: widget.playlistTrack.videoType,
                  ),
                  GestureDetector(
                    onTap: () => _showPlaylistTrackOptions(context),
                    child: const Icon(LucideIcons.ellipsis, color: Colors.grey),
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
