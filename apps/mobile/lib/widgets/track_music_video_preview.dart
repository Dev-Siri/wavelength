import "package:flutter/material.dart";
import "package:hive_flutter/adapters.dart";
import "package:video_player/video_player.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/src/rust/api/tydle_caller.dart";
import "package:wavelength/utils/ttl_store.dart";

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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSetPreview() async {
    try {
      final box = await Hive.openBox(hiveTempUrlKey);
      final ttlStore = TtlStorage(
        box,
        ttl: const Duration(seconds: ytStreamUrlSignValidityHours),
      );
      final cachedUrl = ttlStore.get(widget.musicVideoId);

      String url;
      if (cachedUrl != null) {
        url = cachedUrl;
      } else {
        url = await fetchHighestVideoStreamUrl(videoId: widget.musicVideoId);
        await ttlStore.save(widget.musicVideoId, url);
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await controller.initialize();
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() => _controller = controller);
    } catch (err) {
      DiagnosticsRepo.reportError(
        error: err.toString(),
        source: "_TrackMusicVideoPreviewState._fetchAndSetPreview",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      bottom: (MediaQuery.sizeOf(context).height / 10) + 30,
      child: Opacity(
        opacity: 0.25,
        child: IgnorePointer(
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  key: ValueKey(_controller),
                  width: _controller?.value.size.width,
                  height: _controller?.value.size.height,
                  child: _controller == null ? null : VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
