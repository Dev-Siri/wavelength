import "dart:math" as math;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/bloc/artist/artist_bloc.dart";
import "package:wavelength/bloc/artist/artist_event.dart";
import "package:wavelength/bloc/artist/artist_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/album_tile.dart";
import "package:wavelength/widgets/artist_follow_button.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_preview.dart";
import "package:wavelength/widgets/play_options.dart";
import "package:wavelength/widgets/track_tile.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class ArtistScreen extends StatefulWidget {
  final String browseId;

  const ArtistScreen({super.key, required this.browseId});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  final _artistBloc = ArtistBloc();

  @override
  void initState() {
    _artistBloc.add(ArtistFetchEvent(browseId: widget.browseId));
    super.initState();
  }

  Future<void> _openArtistOnYtMusic(String browseId) async {
    final pageUrl = Uri.parse("$ytMusicChannelSubpathUrl/$browseId");
    if (await canLaunchUrl(pageUrl)) {
      await launchUrl(pageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArtistBloc, ArtistState>(
        bloc: _artistBloc,
        builder: (context, state) {
          if (state is! ArtistSuccessState) {
            if (state is ArtistErrorState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -100),
                    child: Center(
                      child: ErrorMessageDialog(
                        message: "Failed to get artist details from YouTube.",
                        onRetry: () => _artistBloc.add(
                          ArtistFetchEvent(browseId: widget.browseId),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Transform.translate(
              offset: const Offset(0, -100),
              child: const Center(child: LoadingIndicator()),
            );
          }

          final queueableSongs = state.artist.topSongs
              .map(
                (song) => QueueableMusic(
                  videoId: song.videoId,
                  title: song.title,
                  thumbnail: song.thumbnail,
                  artists: [
                    EmbeddedArtist(
                      title: state.artist.title,
                      browseId: state.artist.browseId,
                    ),
                  ],
                  album: song.album,
                  videoType: VideoType.track,
                ),
              )
              .toList();

          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  backgroundColor: Colors.black,
                  leading: Transform.rotate(
                    angle: math.pi / -2,
                    child: BackButton(onPressed: () => context.pop()),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: "${state.artist.browseId}-artist",
                          child: CachedNetworkImage(
                            imageUrl: state.artist.thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: kToolbarHeight + 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.artist.title,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${state.artist.audience} subscribers",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ArtistFollowButton(
                                    browseId: state.artist.browseId,
                                    name: state.artist.title,
                                    thumbnail: state.artist.thumbnail,
                                  ),
                                  AmplButton(
                                    onPressed: () => _openArtistOnYtMusic(
                                      state.artist.browseId,
                                    ),
                                    child: const Text("View On YouTube Music"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: "Top Songs"),
                      Tab(text: "Albums"),
                      Tab(text: "Singles & EPs"),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  // Top Songs tab
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, left: 8),
                        child: PlayOptions(songs: queueableSongs),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: state.artist.topSongs.length,
                          itemBuilder: (context, index) {
                            final song = state.artist.topSongs[index];
                            return TrackTile(
                              queueContext: queueableSongs,
                              playCount: song.playCount,
                              track: Track(
                                videoId: song.videoId,
                                title: song.title,
                                thumbnail: song.thumbnail,
                                artists: [
                                  EmbeddedArtist(
                                    title: state.artist.title,
                                    browseId: state.artist.browseId,
                                  ),
                                ],
                                duration: 0,
                                isExplicit: song.isExplicit,
                                album: song.album,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: state.artist.albums.length,
                    itemBuilder: (context, index) {
                      final album = state.artist.albums[index];
                      return AlbumTile(
                        browseId: album.albumId,
                        title: album.title,
                        thumbnail: album.thumbnail,
                        releaseDate: album.releaseDate,
                      );
                    },
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: state.artist.singlesAndEps.length,
                    itemBuilder: (context, index) {
                      final album = state.artist.singlesAndEps[index];
                      return AlbumTile(
                        browseId: album.albumId,
                        title: album.title,
                        thumbnail: album.thumbnail,
                        releaseDate: album.releaseDate,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
