import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:go_router/go_router.dart";
import "package:shimmer_animation/shimmer_animation.dart";
import "package:uuid/v4.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/stream_download.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_bloc.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_event.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_state.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_bloc.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_event.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_preview.dart";
import "package:wavelength/widgets/playlist_length_text.dart";
import "package:wavelength/widgets/playlist_track_tile.dart";

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  int _playlistTrackDownloadedCount = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthStateAuthorized) {
      context.read<LikedTracksBloc>().add(
        LikedTracksFetchEvent(
          authToken: authState.authToken,
          email: authState.user.email,
        ),
      );
      context.read<LikedTracksPlaylengthBloc>().add(
        LikedTracksPlaylengthFetchEvent(authToken: authState.authToken),
      );
    }
  }

  void _playPlaylistTracks(List<PlaylistTrack> playlistTrack) {
    final queueableSongs = playlistTrack
        .map(
          (track) => QueueableMusic(
            videoId: track.videoId,
            title: track.title,
            thumbnail: track.thumbnail,
            isExplicit: track.isExplicit,
            artists: track.artists,
            videoType: track.videoType,
            album: null,
          ),
        )
        .toList();

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        queueableMusic: queueableSongs.first,
        queueContext: queueableSongs,
      ),
    );
  }

  Future<void> _downloadAllTracks(List<PlaylistTrack> playlistTracks) async {
    final downloadBloc = context.read<DownloadBloc>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          "Downloading playlist...",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    for (final track in playlistTracks) {
      if (await AudioCache.isTrackDownloaded(track.videoId)) {
        continue;
      }

      downloadBloc.add(
        DownloadAddToQueueEvent(
          newDownload: StreamDownload(
            downloadId: const UuidV4().generate(),
            metadata: Track(
              videoId: track.videoId,
              title: track.title,
              thumbnail: track.thumbnail,
              artists: track.artists,
              duration: track.duration,
              isExplicit: track.isExplicit,
              album: null,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: const SvgPicture(
          AssetBytesLoader("assets/vectors/lambda.svg.vec"),
          height: 45,
          width: 45,
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(140, 42, 155, 1),
                    Color.fromRGBO(87, 137, 199, 1),
                    Color.fromRGBO(83, 150, 237, 1),
                  ],
                ),
              ),
              height: 300,
              width: 300,
              child: const Icon(LucideIcons.hash, size: 84),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Likes",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child:
                      BlocBuilder<
                        LikedTracksPlaylengthBloc,
                        LikedTracksPlaylengthState
                      >(
                        builder: (context, state) {
                          if (state is! LikedTracksPlaylengthSuccessState) {
                            if (state is LikedTracksPlaylengthErrorState) {
                              return const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.circleAlert,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "An error occured.",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              );
                            }

                            return Padding(
                              padding: EdgeInsets.only(
                                right:
                                    (MediaQuery.sizeOf(context).width - 30) / 2,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Shimmer(
                                  child: const SizedBox(height: 10),
                                ),
                              ),
                            );
                          }

                          return PlaylistLengthText(
                            playlistTracksLength: state.likesPlaylength,
                            trackDownloadedCount: _playlistTrackDownloadedCount,
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
          BlocConsumer<LikedTracksBloc, LikedTracksState>(
            listener: (context, state) async {
              if (state is! LikedTracksFetchSuccessState) return;
              final downloadCount =
                  await AudioCache.countDownloadedTracksInPlaylist(
                    state.likedTracks.map((song) => song.videoId).toList(),
                  );

              setState(() => _playlistTrackDownloadedCount = downloadCount);
            },
            builder: (context, state) {
              if (state is! LikedTracksFetchSuccessState) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: (MediaQuery.sizeOf(context).height / 4) - 150,
                  ),
                  child: const Center(child: LoadingIndicator()),
                );
              }

              final compatibleTracks = state.likedTracks.asMap().entries.map((
                final entry,
              ) {
                final index = entry.key;
                final likedTrack = entry.value;

                return PlaylistTrack(
                  playlistTrackId: likedTrack.likeId,
                  title: likedTrack.title,
                  thumbnail: likedTrack.thumbnail,
                  positionInPlaylist: index + 1,
                  isExplicit: likedTrack.isExplicit,
                  artists: likedTrack.artists,
                  duration: likedTrack.duration,
                  videoId: likedTrack.videoId,
                  videoType: likedTrack.videoType,
                  playlistId: "likes",
                );
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              _playPlaylistTracks(compatibleTracks),
                          icon: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(LucideIcons.play),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_playlistTrackDownloadedCount !=
                          compatibleTracks.length)
                        IconButton(
                          onPressed: () => _downloadAllTracks(compatibleTracks),
                          icon: const Icon(
                            LucideIcons.hardDriveDownload,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (final song in compatibleTracks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PlaylistTrackTile(
                        playlistTrack: PlaylistTrack(
                          playlistTrackId: song.playlistTrackId,
                          title: song.title,
                          thumbnail: song.thumbnail,
                          positionInPlaylist: song.positionInPlaylist,
                          isExplicit: song.isExplicit,
                          artists: song.artists,
                          duration: song.duration,
                          videoId: song.videoId,
                          videoType: song.videoType,
                          playlistId: song.playlistId,
                        ),
                        allPlaylistTracks: compatibleTracks,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<AppBottomSheetBloc, AppBottomSheetState>(
        builder: (context, state) {
          if (state is AppBottomSheetClosedState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: const MusicPlayerPreview(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
