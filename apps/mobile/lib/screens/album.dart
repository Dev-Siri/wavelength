import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/album_type.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/bloc/album/album_bloc.dart";
import "package:wavelength/bloc/album/album_event.dart";
import "package:wavelength/bloc/album/album_state.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/bloc/is_album_lossless/is_album_lossless_bloc.dart";
import "package:wavelength/bloc/is_album_lossless/is_album_lossless_event.dart";
import "package:wavelength/bloc/is_album_lossless/is_album_lossless_state.dart";
import "package:wavelength/widgets/action_buttons/album_save_button.dart";
import "package:wavelength/widgets/album/album_track_tile.dart";
import "package:wavelength/widgets/album/live_album_cover.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_preview/music_player_preview.dart";
import "package:wavelength/widgets/play_options.dart";

class AlbumScreen extends StatefulWidget {
  final String browseId;

  const AlbumScreen({super.key, required this.browseId});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final isAlbumLosslessBloc = IsAlbumLosslessBloc();

  @override
  void initState() {
    super.initState();
    isAlbumLosslessBloc.add(
      IsAlbumLosslessFetchEvent(albumId: widget.browseId),
    );
    context.read<AlbumBloc>().add(AlbumFetchEvent(browseId: widget.browseId));
  }

  void _navigateToArtist(EmbeddedArtist artist) {
    if (artist.browseId == "VARIOUS_ARTISTS") {
      return;
    }

    context.push("/artist/${artist.browseId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<IsAlbumLosslessBloc, IsAlbumLosslessState>(
        bloc: isAlbumLosslessBloc,
        builder: (context, losslessState) {
          return BlocBuilder<AlbumBloc, AlbumState>(
            builder: (context, state) {
              if (state is! AlbumFetchSuccessState) {
                return const Center(child: LoadingIndicator());
              }

              var detailsText =
                  "${state.album.albumType.toFormatted()}/${state.album.release} • ${state.album.totalDuration}";

              if (losslessState is IsAlbumLosslessSuccessState &&
                  losslessState.isLossless) {
                detailsText += " • λ Lossless";
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: MediaQuery.sizeOf(context).height / 2,
                    pinned: true,
                    forceElevated: true,
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    elevation: 0,
                    centerTitle: true,
                    actions: [AlbumSaveButton(albumId: widget.browseId)],
                    title: Builder(
                      builder: (context) {
                        final settings = context
                            .dependOnInheritedWidgetOfExactType<
                              FlexibleSpaceBarSettings
                            >();

                        final t =
                            ((settings!.currentExtent - settings.minExtent) /
                                    (settings.maxExtent - settings.minExtent))
                                .clamp(0.0, 1.0);

                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: t < 0.3 ? 1 : 0,
                          child: Text(
                            state.album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          SizedBox.expand(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: state.album.cover,
                                  fit: BoxFit.cover,
                                ),
                                Container(color: Colors.black.withAlpha(51)),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height / 2,
                                    width:
                                        // 5% correction
                                        MediaQuery.sizeOf(context).width +
                                        (MediaQuery.sizeOf(context).width *
                                            0.05),
                                    child: LiveAlbumCover(
                                      videoId:
                                          state.album.albumTracks[0].videoId,
                                      albumId: widget.browseId,
                                    ),
                                  ),
                                ),
                                Container(color: Colors.black.withAlpha(51)),
                              ],
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.sizeOf(context).height * 0.05,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      state.album.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        _navigateToArtist(state.album.artist),
                                    child: Text(
                                      state.album.artist.title,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    detailsText,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        PlayOptions(
                                          glass: true,
                                          sourceLabel: state.album.title,
                                          musicContext: MusicContextTypeAlbum(
                                            albumId: widget.browseId,
                                          ),
                                          songs: state.album.albumTracks
                                              .map(
                                                (track) => QueueableMusic(
                                                  videoId: track.videoId,
                                                  isExplicit: track.isExplicit,
                                                  duration: track.duration,
                                                  title: track.title,
                                                  thumbnail: state.album.cover,
                                                  artists: [state.album.artist],
                                                  album: EmbeddedAlbum(
                                                    title: state.album.title,
                                                    browseId: widget.browseId,
                                                  ),
                                                  videoType: VideoType.track,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(bottom: 10)),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final albumTrack = state.album.albumTracks[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AlbumTrackTile(
                          albumId: widget.browseId,
                          album: state.album,
                          track: albumTrack,
                        ),
                      );
                    }, childCount: state.album.albumTracks.length),
                  ),
                ],
              );
            },
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
