import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/music_video_preview.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_play_options.dart";
import "package:wavelength/widgets/music_player_progress_bar.dart";
import "package:wavelength/widgets/track_music_video_preview.dart";

class PlayingNowPreviewPresenter extends StatefulWidget {
  final Future<void> Function(String) onTrackChange;

  const PlayingNowPreviewPresenter({super.key, required this.onTrackChange});

  @override
  State<PlayingNowPreviewPresenter> createState() =>
      _PlayingNowPreviewPresenterState();
}

class _PlayingNowPreviewPresenterState
    extends State<PlayingNowPreviewPresenter> {
  String? _musicVideoId;
  Color? _trackThemeColor;

  Future<void> _fetchMusicVideo({
    required String title,
    required String author,
  }) async {
    final response = await TrackRepo.fetchTrackMusicVideo(
      title: title,
      artist: author,
    );

    if (response is ApiResponseSuccess<MusicVideoPreview> && mounted) {
      setState(() => _musicVideoId = response.data.videoId);
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

    widget.onTrackChange(track.videoId);
    _fetchMusicVideo(title: track.title, author: track.author);
  }

  @override
  void initState() {
    final musicPlayerTrackState = context.read<MusicPlayerTrackBloc>().state;

    if (musicPlayerTrackState is MusicPlayerTrackPlayingNowState) {
      _blocListener(context, musicPlayerTrackState);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      listener: _blocListener,
      builder: (context, state) {
        if (state is! MusicPlayerTrackPlayingNowState) {
          if (state is MusicPlayerTrackLoadingState) {
            return const Center(child: LoadingIndicator());
          }

          return const SizedBox.shrink();
        }

        final track = state.playingNowTrack;

        final textColor =
            ThemeData.estimateBrightnessForColor(
                  _trackThemeColor ?? Colors.black,
                ) ==
                Brightness.dark
            ? Colors.white
            : Colors.black;

        final videoPreviewId = track.videoType == VideoType.track
            ? _musicVideoId
            : track.videoId;

        return SizedBox.expand(
          child: Stack(
            children: [
              if (videoPreviewId != null)
                TrackMusicVideoPreview(
                  key: ValueKey(videoPreviewId),
                  musicVideoId: videoPreviewId,
                ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: getTrackThumbnail(track.videoId),
                              fit: BoxFit.cover,
                              height: 65,
                              width: 65,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  child: Text(
                                    track.title,
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
                          return const SizedBox.shrink();
                        }

                        return MusicPlayerProgressBar(
                          duration: state.totalDuration,
                          position: state.currentDuration,
                          onSeek: (value) =>
                              context.read<MusicPlayerDurationBloc>().add(
                                MusicPlayerDurationSeekToEvent(
                                  newDuration: value,
                                  totalDuration: state.totalDuration,
                                ),
                              ),
                        );
                      },
                    ),
                    const MusicPlayerPlayOptions(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
