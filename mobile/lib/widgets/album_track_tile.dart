import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/api/models/album.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/add_to_playlist_bottom_sheet.dart";
import "package:wavelength/widgets/explicit_indicator.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class AlbumTrackTile extends StatelessWidget {
  final String albumId;
  final Album album;
  final AlbumTrack track;

  const AlbumTrackTile({
    super.key,
    required this.albumId,
    required this.album,
    required this.track,
  });

  Future<void> _playTrack(BuildContext context) async {
    final trackBloc = context.read<MusicPlayerTrackBloc>();
    final embeddedAlbum = EmbeddedAlbum(title: album.title, browseId: albumId);
    final queueableMusic = QueueableMusic(
      videoId: track.videoId,
      title: track.title,
      thumbnail: album.cover,
      artists: [album.artist],
      videoType: VideoType.track,
      album: embeddedAlbum,
    );

    trackBloc.add(
      MusicPlayerTrackLoadEvent(
        queueContext: album.albumTracks
            .map(
              (track) => QueueableMusic(
                videoId: track.videoId,
                title: track.title,
                thumbnail: album.cover,
                artists: [album.artist],
                album: embeddedAlbum,
                videoType: VideoType.track,
              ),
            )
            .toList(),
        queueableMusic: queueableMusic,
      ),
    );
  }

  void _openPlaylistOptions(BuildContext context) =>
      context.read<AppBottomSheetBloc>().add(
        AppBottomSheetOpenEvent(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => AddToPlaylistBottomSheet(
            track: Track(
              videoId: track.videoId,
              title: track.title,
              thumbnail: album.cover,
              artists: [album.artist],
              duration: track.duration,
              isExplicit: track.isExplicit,
              album: EmbeddedAlbum(title: album.title, browseId: albumId),
            ),
            videoType: VideoType.track,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AmplButton(
      padding: EdgeInsets.zero,
      onPressed: () => _playTrack(context),
      onLongPress: () => _openPlaylistOptions(context),
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
                    state.playingNowTrack.videoId == track.videoId;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isThisTrackPlaying ? 0.2 : 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: album.cover,
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
                Row(
                  children: [
                    if (track.isExplicit)
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: ExplicitIndicator(),
                      ),
                    SizedBox(
                      width:
                          MediaQuery.sizeOf(context).width -
                          (track.isExplicit ? 200 : 150),
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
                  ],
                ),
              ],
            ),
            const Spacer(),
            AmplIconButton(
              onPressed: () => _openPlaylistOptions(context),
              icon: Icon(LucideIcons.ellipsis, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
