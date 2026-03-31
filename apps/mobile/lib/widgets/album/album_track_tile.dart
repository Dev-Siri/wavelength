import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/api/models/album.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/widgets/bottom_sheets/track_options_bottom_sheet.dart";
import "package:wavelength/widgets/track/track_label.dart";
import "package:wavelength/widgets/track/track_like_button.dart";
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

    trackBloc.add(
      MusicPlayerTrackLoadEvent(
        context: MusicContextTypeAlbum(albumId: albumId),
        sourceLabel: album.title,
        trackId: track.videoId,
        tracks: album.albumTracks
            .map(
              (track) => QueueableMusic(
                videoId: track.videoId,
                title: track.title,
                duration: track.duration,
                isExplicit: track.isExplicit,
                thumbnail: album.cover,
                artists: track.artists.isEmpty ? [album.artist] : track.artists,
                album: embeddedAlbum,
                videoType: VideoType.track,
              ),
            )
            .toList(),
      ),
    );
  }

  void _openPlaylistOptions(BuildContext context) =>
      context.read<AppBottomSheetBloc>().add(
        AppBottomSheetOpenEvent(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => TrackOptionsBottomSheet(
            track: Track(
              videoId: track.videoId,
              title: track.title,
              thumbnail: album.cover,
              artists: track.artists.isEmpty ? [album.artist] : track.artists,
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
    final artists =
        track.artists.isEmpty || track.artists[0].title == "VARIOUS_ARTISTS"
        ? [album.artist]
        : track.artists;
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
                      opacity: isThisTrackPlaying ? 0 : 1,
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            track.positionInAlbum.toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
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
            TrackLabel(
              title: track.title,
              artists: artists,
              isExplicit: track.isExplicit,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  durationify(Duration(seconds: track.duration)),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                TrackLikeButton(
                  track: Track(
                    videoId: track.videoId,
                    title: track.title,
                    thumbnail: album.cover,
                    artists: track.artists,
                    duration: track.duration,
                    isExplicit: track.isExplicit,
                    album: EmbeddedAlbum(title: album.title, browseId: albumId),
                  ),
                  videoType: VideoType.track,
                ),
                GestureDetector(
                  onTap: () => _openPlaylistOptions(context),
                  child: Icon(
                    LucideIcons.ellipsis,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
