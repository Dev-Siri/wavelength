import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/explicit_indicator.dart";
import "package:wavelength/widgets/like_button.dart";
import "package:wavelength/widgets/playlist_track_extended_options.dart";
import "package:wavelength/widgets/track_options_bottom_sheet.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class PlaylistTrackTile extends StatefulWidget {
  final List<PlaylistTrack> allPlaylistTracks;
  final PlaylistTrack playlistTrack;

  const PlaylistTrackTile({
    super.key,
    required this.playlistTrack,
    required this.allPlaylistTracks,
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
    final isDownloaded = await AudioCache.isTrackDownloaded(
      widget.playlistTrack.videoId,
    );

    if (mounted) setState(() => _isTrackDownloaded = isDownloaded);
  }

  void _playSong(BuildContext context) {
    final queueableMusic = QueueableMusic(
      videoId: widget.playlistTrack.videoId,
      title: widget.playlistTrack.title,
      isExplicit: widget.playlistTrack.isExplicit,
      thumbnail: getTrackThumbnail(widget.playlistTrack.videoId),
      artists: widget.playlistTrack.artists,
      videoType: widget.playlistTrack.videoType,
      album: null,
    );

    final queue = widget.allPlaylistTracks
        .map(
          (track) => QueueableMusic(
            videoId: track.videoId,
            title: track.title,
            isExplicit: track.isExplicit,
            thumbnail: getTrackThumbnail(track.videoId),
            artists: track.artists,
            videoType: track.videoType,
            album: null,
          ),
        )
        .toList();

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        contextId: widget.playlistTrack.playlistId,
        queueableMusic: queueableMusic,
        queueContext: queue,
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
      album: null,
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
                    state.playingNowTrack.videoId ==
                        widget.playlistTrack.videoId;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isThisTrackPlaying ? 0.2 : 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.playlistTrack.thumbnail,
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
                  width: (MediaQuery.sizeOf(context).width / 1.4) - 70,
                  child: Text(
                    widget.playlistTrack.title,
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
                    if (_isTrackDownloaded)
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          LucideIcons.circleArrowDown,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    if (widget.playlistTrack.isExplicit)
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: ExplicitIndicator(),
                      ),
                    SizedBox(
                      width:
                          (MediaQuery.sizeOf(context).width / 2) -
                          (_isTrackDownloaded ? 20 : 0),
                      child: Text(
                        formatList(
                          widget.playlistTrack.artists.map(
                            (artist) => artist.title,
                          ),
                        ),
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
              durationify(Duration(seconds: widget.playlistTrack.duration)),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            LikeButton(
              track: Track(
                videoId: widget.playlistTrack.videoId,
                title: widget.playlistTrack.title,
                thumbnail: widget.playlistTrack.thumbnail,
                artists: widget.playlistTrack.artists,
                duration: widget.playlistTrack.duration,
                isExplicit: widget.playlistTrack.isExplicit,
                album: null,
              ),
              videoType: widget.playlistTrack.videoType,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: GestureDetector(
                onTap: () => _showPlaylistTrackOptions(context),
                child: const Icon(LucideIcons.ellipsis, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
