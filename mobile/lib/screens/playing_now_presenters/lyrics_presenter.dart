import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/lyrics/lyrics_bloc.dart";
import "package:wavelength/bloc/lyrics/lyrics_event.dart";
import "package:wavelength/bloc/lyrics/lyrics_state.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_play_options.dart";

class LyricsPresenter extends StatefulWidget {
  const LyricsPresenter({super.key});

  @override
  State<LyricsPresenter> createState() => _LyricsPresenterState();
}

class _LyricsPresenterState extends State<LyricsPresenter> {
  final _lyricsBloc = LyricsBloc();

  int? _activeIndex;
  List<GlobalKey> lyricKeys = [];

  @override
  void initState() {
    final musicPlayerTrackState = context.read<MusicPlayerTrackBloc>().state;

    if (musicPlayerTrackState is MusicPlayerTrackPlayingNowState) {
      _lyricsBloc.add(
        LyricsFetchEvent(
          trackId: musicPlayerTrackState.playingNowTrack.videoId,
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          BlocBuilder<LyricsBloc, LyricsState>(
            bloc: _lyricsBloc,
            builder: (context, state) {
              if (state is LyricsFetchSuccessState) {
                lyricKeys = List.generate(
                  state.lyrics.length,
                  (_) => GlobalKey(),
                );
              }
              return Expanded(
                flex: 2,
                child: state is! LyricsFetchSuccessState
                    ? LoadingIndicator()
                    : ListView.builder(
                        itemCount: state.lyrics.length,
                        itemBuilder: (context, index) {
                          final lyric = state.lyrics[index];

                          return KeyedSubtree(
                            key: lyricKeys[index],
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child:
                                  BlocBuilder<
                                    MusicPlayerDurationBloc,
                                    MusicPlayerDurationState
                                  >(
                                    builder: (context, state) {
                                      // I'm very sorry if you're eyes had to see all of this.
                                      final isProgressStateAvailable =
                                          state
                                              is MusicPlayerDurationAvailableState;

                                      final endMs = lyric.startMs + lyric.durMs;
                                      final isActive =
                                          isProgressStateAvailable &&
                                          (state
                                                      .currentDuration
                                                      .inMilliseconds >
                                                  lyric.startMs &&
                                              state
                                                      .currentDuration
                                                      .inMilliseconds <
                                                  endMs);

                                      if (isActive && _activeIndex != index) {
                                        _activeIndex = index;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              final context = lyricKeys[index]
                                                  .currentContext;
                                              if (context != null) {
                                                Scrollable.ensureVisible(
                                                  context,
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                  alignment: 0.5,
                                                );
                                              }
                                            });
                                      }

                                      final lyricTextColor =
                                          isProgressStateAvailable
                                          ? ((state
                                                            .currentDuration
                                                            .inMilliseconds >
                                                        lyric.startMs &&
                                                    state
                                                            .currentDuration
                                                            .inMilliseconds <
                                                        endMs)
                                                ? Colors.white
                                                : state
                                                          .currentDuration
                                                          .inMilliseconds >
                                                      lyric.startMs
                                                ? Colors.white.withAlpha(180)
                                                : Colors.grey)
                                          : Colors.grey;

                                      final musicPlayerDurationBloc = context
                                          .read<MusicPlayerDurationBloc>();
                                      final musicPlayerDurationState =
                                          musicPlayerDurationBloc.state;

                                      return GestureDetector(
                                        onTap: () => musicPlayerDurationBloc.add(
                                          MusicPlayerDurationSeekToEvent(
                                            totalDuration:
                                                musicPlayerDurationState
                                                    is MusicPlayerDurationAvailableState
                                                ? musicPlayerDurationState
                                                      .totalDuration
                                                : Duration.zero,
                                            newDuration: Duration(
                                              milliseconds: lyric.startMs,
                                            ),
                                          ),
                                        ),
                                        child: AnimatedDefaultTextStyle(
                                          duration: Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                            color: lyricTextColor,
                                          ),
                                          child: Text(lyric.text),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
          SizedBox(height: 10),
          MusicPlayerPlayOptions(),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
