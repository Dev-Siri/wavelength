import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/models/video.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/widgets/add_to_playlist_bottom_sheet.dart";
import "package:youtube_player_flutter/youtube_player_flutter.dart";

class VideoCard extends StatefulWidget {
  final Video video;

  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  YoutubePlayerController? _tempYoutubePlayerController;
  Duration? videoDuration;

  void _initTempVideo(String videoId) {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: true),
    );

    controller.addListener(_onTempPlayerReady);

    setState(() => _tempYoutubePlayerController = controller);

    _tempYoutubePlayerController?.load(videoId);
  }

  void _onTempPlayerReady() {
    final vDuration = _tempYoutubePlayerController!.metadata.duration;

    if (vDuration != Duration.zero) {
      setState(() {
        videoDuration = vDuration;
        _tempYoutubePlayerController = null;
      });
    }
  }

  void _playYouTubeVideo(BuildContext context) {
    final coverImageUrl =
        "$ytImgApiUrl/vi/${widget.video.id.videoId}/maxresdefault.jpg";

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: widget.video.id.videoId,
          title: widget.video.snippet.title ?? "",
          thumbnail: coverImageUrl,
          author: widget.video.snippet.channelTitle ?? "",
          videoType: VideoType.uvideo,
        ),
      ),
    );
  }

  void _showPlaylistAdditionDialog(BuildContext context) {
    _initTempVideo(widget.video.id.videoId);

    if (videoDuration == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => AddToPlaylistBottomSheet(
        track: Track(
          videoId: widget.video.id.videoId,
          title: widget.video.snippet.title ?? "",
          thumbnail:
              "$ytImgApiUrl/vi/${widget.video.id.videoId}/maxresdefault.jpg",
          author: widget.video.snippet.channelId ?? "",
          duration: durationify(videoDuration ?? Duration.zero),
          isExplicit: false,
        ),
        videoType: VideoType.track,
      ),
    );
  }

  @override
  void dispose() {
    _tempYoutubePlayerController?.dispose();
    super.dispose();
  }

  // showModalBottomSheet(
  @override
  Widget build(BuildContext context) {
    final thumbnail = CachedNetworkImage(
      imageUrl:
          widget.video.snippet.thumbnails.high.url ??
          widget.video.snippet.thumbnails.medium.url ??
          widget.video.snippet.thumbnails.normal.url ??
          "",
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    final title = decodeHtmlSpecialChars(widget.video.snippet.title ?? "");

    return Stack(
      children: [
        if (_tempYoutubePlayerController != null)
          YoutubePlayer(controller: _tempYoutubePlayerController!, width: 1),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Platform.isAndroid
                  ? MaterialButton(
                      onPressed: () => _playYouTubeVideo(context),
                      padding: EdgeInsets.zero,
                      child: thumbnail,
                    )
                  : CupertinoButton(
                      onPressed: () => _playYouTubeVideo(context),
                      padding: EdgeInsets.zero,
                      child: thumbnail,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  children: [
                    TextSpan(
                      text: title.length > 50
                          ? "${title.substring(0, 50)}..."
                          : title,
                    ),
                    TextSpan(
                      text: " - ${widget.video.snippet.channelTitle}",
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: () => _showPlaylistAdditionDialog(context),
                      child: Icon(
                        LucideIcons.circlePlus,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        minWidth: 20,
                        onPressed: () => _showPlaylistAdditionDialog(context),
                        child: Icon(LucideIcons.circlePlus),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
