import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:text_scroll/text_scroll.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/animations/blur_in_animation.dart";
import "package:wavelength/widgets/hifi_badge.dart";
import "package:wavelength/widgets/music_player/music_player_lyrics_list.dart";
import "package:wavelength/widgets/music_player/music_player_play_controls.dart";
import "package:wavelength/widgets/music_player/music_player_progress_bar.dart";

class LyricsPresenter extends StatefulWidget {
  const LyricsPresenter({super.key});

  @override
  State<LyricsPresenter> createState() => _LyricsPresenterState();
}

class _LyricsPresenterState extends State<LyricsPresenter> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
        builder: (context, state) {
          if (state is! MusicPlayerTrackPlayingNowState) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MusicPlayerLyricsList(
                        key: Key("${state.playingNowTrack.videoId}-lyrics"),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: MediaQuery.sizeOf(context).height * 0.35,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromARGB(220, 0, 0, 0),
                                Color.fromARGB(119, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    BlurInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.sizeOf(context).height * 0.10,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: "playing-now-cover",
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: getUpscaledTrackThumbnail(
                                      state.playingNowTrack.thumbnail,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.65,
                                    child: TextScroll(
                                      state.playingNowTrack.title,
                                      mode: TextScrollMode.endless,
                                      fadeBorderSide: FadeBorderSide.both,
                                      velocity: const Velocity(
                                        pixelsPerSecond: Offset(20, 0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.65,
                                    child: TextScroll(
                                      formatList(
                                        state.playingNowTrack.artists.map(
                                          (artist) => artist.title,
                                        ),
                                      ),
                                      mode: TextScrollMode.bouncing,
                                      fadeBorderSide: FadeBorderSide.both,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<MusicPlayerDurationBloc, MusicPlayerDurationState>(
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
          );
        },
      ),
    );
  }
}
