import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/video.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/parse.dart";

class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({super.key, required this.video});

  void _playYouTubeVideo(BuildContext context) {
    final coverImageUrl =
        "$ytImgApiUrl/vi/${video.id.videoId}/maxresdefault.jpg";

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: video.id.videoId,
          title: video.snippet.title ?? "",
          thumbnail: coverImageUrl,
          author: video.snippet.channelTitle ?? "",
          videoType: VideoType.uvideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = CachedNetworkImage(
      imageUrl:
          video.snippet.thumbnails.high.url ??
          video.snippet.thumbnails.medium.url ??
          video.snippet.thumbnails.normal.url ??
          "",
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    final title = decodeHtmlSpecialChars(video.snippet.title ?? "");

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child:
                  Platform.isAndroid
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
                      text:
                          title.length > 50
                              ? "${title.substring(0, 50)}..."
                              : title,
                    ),
                    TextSpan(
                      text: " - ${video.snippet.channelTitle}",
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
              child:
                  Platform.isIOS
                      ? CupertinoButton(
                        onPressed: () => print("add ${video.id.videoId}"),
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
                          onPressed: () => print("add ${video.id.videoId}"),
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
