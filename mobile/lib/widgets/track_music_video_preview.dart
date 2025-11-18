import "package:flutter/material.dart";
import "package:video_player/video_player.dart";
import "package:wavelength/src/rust/api/tydle_caller.dart";

class TrackMusicVideoPreview extends StatefulWidget {
  final String musicVideoId;

  const TrackMusicVideoPreview({super.key, required this.musicVideoId});

  @override
  State<TrackMusicVideoPreview> createState() => _TrackMusicVideoPreviewState();
}

class _TrackMusicVideoPreviewState extends State<TrackMusicVideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _fetchAndSetPreview();
  }

  Future<void> _fetchAndSetPreview() async {
    final url = await fetchHighestVideoStreamUrl(videoId: widget.musicVideoId);
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(url),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize()
          ..setLooping(true)
          ..setVolume(0)
          ..play();
    // Display the first frame.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox.shrink();

    return Positioned.fill(
      bottom: (MediaQuery.of(context).size.height / 10) + 30,
      child: Opacity(
        opacity: 0.25,
        child: IgnorePointer(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 9 / 16,
              width: MediaQuery.of(context).size.width,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}
