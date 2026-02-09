import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/api/models/enums/album_type.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/bloc/album/album_bloc.dart";
import "package:wavelength/bloc/album/album_event.dart";
import "package:wavelength/bloc/album/album_state.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/widgets/album_track_tile.dart";
import "package:wavelength/widgets/brand_cover_image.dart";
import "package:wavelength/widgets/common_app_bar.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_preview.dart";
import "package:wavelength/widgets/play_options.dart";

class AlbumScreen extends StatefulWidget {
  final String browseId;

  const AlbumScreen({super.key, required this.browseId});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AlbumBloc>().add(AlbumFetchEvent(browseId: widget.browseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          if (state is! AlbumFetchSuccessState) {
            return const Center(child: LoadingIndicator());
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Hero(
                  tag: "${widget.browseId}-album",
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: BrandCoverImage(imageUrl: state.album.cover),
                  ),
                ),
              ),
              Center(
                child: Text(
                  state.album.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.album.albumType.toFormatted(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    " by ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push("/artist/${state.album.artist.browseId}"),
                    child: Text(
                      state.album.artist.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    " • ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  Text(
                    state.album.release,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: PlayOptions(
                  contextId: "${widget.browseId}-album",
                  songs: state.album.albumTracks
                      .map(
                        (track) => QueueableMusic(
                          videoId: track.videoId,
                          isExplicit: track.isExplicit,
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
              ),
              for (final albumTrack in state.album.albumTracks)
                AlbumTrackTile(
                  albumId: widget.browseId,
                  album: state.album,
                  track: albumTrack,
                ),
            ],
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
