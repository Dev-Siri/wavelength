import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:video_player/video_player.dart";
import "package:wavelength/bloc/live_album_cover/live_album_cover_bloc.dart";
import "package:wavelength/bloc/live_album_cover/live_album_cover_event.dart";
import "package:wavelength/bloc/live_album_cover/live_album_cover_state.dart";

class LiveAlbumCover extends StatefulWidget {
  final String videoId;
  final String albumId;

  const LiveAlbumCover({
    super.key,
    required this.videoId,
    required this.albumId,
  });

  @override
  State<LiveAlbumCover> createState() => _LiveAlbumCoverState();
}

class _LiveAlbumCoverState extends State<LiveAlbumCover> {
  final _liveAlbumCoverBloc = LiveAlbumCoverBloc();

  VideoPlayerController? _previewPlayerController;

  @override
  void initState() {
    super.initState();
    _liveAlbumCoverBloc.add(
      LiveAlbumCoverFetchEvent(
        albumId: widget.albumId,
        videoId: widget.videoId,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _previewPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _liveAlbumCoverBloc,
      listener: (context, state) async {
        if (state is! LiveAlbumCoverFetchSuccessState) return;

        final url = state.liveAlbumCoverUri;

        if (url != null) {
          _previewPlayerController =
              VideoPlayerController.networkUrl(
                  Uri.parse(url),
                  videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
                )
                ..setVolume(0)
                ..setLooping(true)
                ..initialize().then((_) async {
                  await _previewPlayerController?.play();
                  setState(() {});
                });
        }
      },
      builder: (context, state) {
        if (_previewPlayerController == null) return const SizedBox.shrink();

        return VideoPlayer(_previewPlayerController!);
      },
    );
  }
}
