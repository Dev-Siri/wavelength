import "package:flutter/material.dart";
import "package:youtube_player_flutter/youtube_player_flutter.dart";

class TrackMusicVideoPreview extends StatefulWidget {
  final String musicVideoId;

  const TrackMusicVideoPreview({super.key, required this.musicVideoId});

  @override
  State<TrackMusicVideoPreview> createState() => _TrackMusicVideoPreviewState();
}

class _TrackMusicVideoPreviewState extends State<TrackMusicVideoPreview> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.musicVideoId,
      flags: YoutubePlayerFlags(
        mute: true,
        hideControls: true,
        controlsVisibleAtStart: false,
        showLiveFullscreenButton: false,
        autoPlay: true,
        enableCaption: false,
        startAt: 5,
      ),
    )..mute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      bottom: (MediaQuery.of(context).size.height / 10) + 30,
      child: Opacity(
        opacity: 0.25,
        child: IgnorePointer(
          child: Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 9 / 16,
                  width: MediaQuery.of(context).size.width,
                  child: YoutubePlayer(
                    controller: _youtubePlayerController,
                    onEnded: (_) =>
                        _youtubePlayerController.seekTo(Duration(seconds: 0)),
                    showVideoProgressIndicator: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
