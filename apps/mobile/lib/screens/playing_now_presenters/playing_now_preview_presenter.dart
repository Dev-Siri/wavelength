import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:text_scroll/text_scroll.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/widgets/animations/blur_in_animation.dart";
import "package:wavelength/widgets/hifi_badge.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player/music_player_play_controls.dart";
import "package:wavelength/widgets/music_player/music_player_progress_bar.dart";
import "package:wavelength/widgets/music_player/music_player_save_options.dart";

class PlayingNowPreviewPresenter extends StatefulWidget {
  final void Function(String thumbnail) onTrackChange;

  const PlayingNowPreviewPresenter({super.key, required this.onTrackChange});

  @override
  State<PlayingNowPreviewPresenter> createState() =>
      _PlayingNowPreviewPresenterState();
}

class _PlayingNowPreviewPresenterState
    extends State<PlayingNowPreviewPresenter> {
  Color? _trackThemeColor;

  Future<void> _blocListener(
    BuildContext context,
    MusicPlayerTrackState state,
  ) async {
    if (state is! MusicPlayerTrackPlayingNowState ||
        state.playingNowTrack.videoType == VideoType.uvideo) {
      return;
    }

    widget.onTrackChange(state.playingNowTrack.thumbnail);
  }

  @override
  void initState() {
    super.initState();
    final musicPlayerTrackState = context.read<MusicPlayerTrackBloc>().state;

    if (musicPlayerTrackState is MusicPlayerTrackPlayingNowState) {
      _blocListener(context, musicPlayerTrackState);
    }
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

        return Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BlurInAnimation(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: TextScroll(
                                  track.title,
                                  mode: TextScrollMode.endless,
                                  fadedBorder: true,
                                  fadedBorderWidth: 0.25,
                                  fadeBorderSide: FadeBorderSide.both,
                                  velocity: const Velocity(
                                    pixelsPerSecond: Offset(20, 0),
                                  ),
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: textColor,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.6,
                                child: TextScroll(
                                  formatList(
                                    track.artists.map((artist) => artist.title),
                                  ),
                                  mode: TextScrollMode.endless,
                                  fadedBorder: true,
                                  fadeBorderSide: FadeBorderSide.both,
                                  velocity: const Velocity(
                                    pixelsPerSecond: Offset(20, 0),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            child: const MusicPlayerSaveOptions(),
                          ),
                        ],
                      ),
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
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: const BlurInAnimation(child: HifiBadge()),
                  ),
                  const MusicPlayerControls(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
