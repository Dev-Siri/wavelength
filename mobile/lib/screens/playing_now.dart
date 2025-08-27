import "dart:math" as math;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/api/models/music_video_preview.dart";
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/parse.dart";
import "package:wavelength/widgets/music_player_play_options.dart";
import "package:wavelength/widgets/music_player_progess_bar.dart";
import "package:wavelength/widgets/track_music_video_preview.dart";

class PlayingNowScreen extends StatefulWidget {
  const PlayingNowScreen({super.key});

  @override
  State<PlayingNowScreen> createState() => _PlayingNowScreenState();
}

class _PlayingNowScreenState extends State<PlayingNowScreen> {
  String? _musicVideoId;
  Color? _trackThemeColor;

  Future<void> _fetchTrackThemeColor(String videoId) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final trackThemeColorKey = "$videoId-t_color";
    final trackColor = sharedPrefs.getStringList(trackThemeColorKey);

    if (trackColor != null) {
      final r = int.parse(trackColor[0]);
      final g = int.parse(trackColor[1]);
      final b = int.parse(trackColor[2]);

      _trackThemeColor = Color.fromRGBO(r, g, b, 1);
      return;
    }

    final colorResponse = await TrackRepo.fetchTrackThemeColor(
      trackId: videoId,
    );

    if (colorResponse.success) {
      final themeRgb = colorResponse.data as ThemeColor;

      await sharedPrefs.setStringList(trackThemeColorKey, [
        themeRgb.r.toString(),
        themeRgb.g.toString(),
        themeRgb.b.toString(),
      ]);

      setState(
        () =>
            _trackThemeColor = Color.fromRGBO(
              themeRgb.r,
              themeRgb.g,
              themeRgb.b,
              1,
            ),
      );
    }
  }

  Future<void> _fetchMusicVideo({
    required String videoId,
    required String title,
    required String author,
  }) async {
    final response = await TrackRepo.fetchTrackMusicVideo(
      trackId: videoId,
      title: title,
      artist: author,
    );

    if (response.success) {
      final musicVideoPreview = response.data as MusicVideoPreview;
      setState(() => _musicVideoId = musicVideoPreview.videoId);
    }
  }

  Future<void> _blocListener(
    BuildContext context,
    MusicPlayerTrackState state,
  ) async {
    if (state is! MusicPlayerTrackPlayingNowState ||
        state.playingNowTrack.videoType == VideoType.uvideo) {
      return;
    }

    final track = state.playingNowTrack;

    _fetchMusicVideo(
      videoId: track.videoId,
      title: track.title,
      author: track.author,
    );
    _fetchTrackThemeColor(track.videoId);
  }

  @override
  void initState() {
    final state = context.read<MusicPlayerTrackBloc>().state;

    _blocListener(context, state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      color: _trackThemeColor ?? Colors.black,
      child: Scaffold(
        appBar: AppBar(
          leading: Transform.rotate(
            angle: math.pi / -2,
            child: BackButton(onPressed: () => context.pop()),
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: BlocConsumer<MusicPlayerTrackBloc, MusicPlayerTrackState>(
          listener: _blocListener,
          builder: (context, state) {
            if (state is! MusicPlayerTrackPlayingNowState) {
              return SizedBox.shrink();
            }

            final track = state.playingNowTrack;

            final textColor =
                ThemeData.estimateBrightnessForColor(
                          _trackThemeColor ?? Colors.black,
                        ) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black;

            final trackTitle = decodeHtmlSpecialChars(track.title);
            final videoPreviewId =
                track.videoType == VideoType.track
                    ? _musicVideoId
                    : track.videoId;

            return Stack(
              children: [
                if (videoPreviewId != null)
                  TrackMusicVideoPreview(
                    key: ValueKey(videoPreviewId),
                    musicVideoId: videoPreviewId,
                  ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height / 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "$ytImgApiUrl/vi/${track.videoId}/maxresdefault.jpg",
                                  fit: BoxFit.cover,
                                  height: 65,
                                  width: 65,
                                ),
                              ),
                              SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width /
                                          1.5,
                                      child: Text(
                                        trackTitle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          height: 1.1,
                                          color: textColor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      track.author,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<
                          MusicPlayerDurationBloc,
                          MusicPlayerDurationState
                        >(
                          builder: (context, state) {
                            if (state is! MusicPlayerDurationAvailableState) {
                              return SizedBox.shrink();
                            }

                            return MusicPlayerProgessBar(
                              duration: state.totalDuration,
                              position: state.currentDuration,
                              onSeek:
                                  (value) => context
                                      .read<MusicPlayerDurationBloc>()
                                      .add(
                                        MusicPlayerDurationSeekToEvent(
                                          newDuration: value,
                                          totalDuration: state.totalDuration,
                                        ),
                                      ),
                            );
                          },
                        ),
                        MusicPlayerPlayOptions(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
