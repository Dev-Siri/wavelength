import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/lyrics/lyrics_bloc.dart";
import "package:wavelength/bloc/lyrics/lyrics_event.dart";
import "package:wavelength/bloc/lyrics/lyrics_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/dialogs/error_message_dialog.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player/music_player_lyric.dart";

class MusicPlayerLyricsList extends StatefulWidget {
  const MusicPlayerLyricsList({super.key});

  @override
  State<MusicPlayerLyricsList> createState() => _MusicPlayerLyricsListState();
}

class _MusicPlayerLyricsListState extends State<MusicPlayerLyricsList> {
  final _lyricsBloc = LyricsBloc();

  List<GlobalKey> _lyricKeys = [];
  int? _activeIndex;

  void _triggerFetchLyricsEvent() {
    final musicPlayerTrackState = context.read<MusicPlayerTrackBloc>().state;

    if (musicPlayerTrackState is MusicPlayerTrackPlayingNowState) {
      _lyricsBloc.add(
        LyricsFetchEvent(
          trackId: musicPlayerTrackState.playingNowTrack.videoId,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _triggerFetchLyricsEvent();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LyricsBloc, LyricsState>(
      bloc: _lyricsBloc,
      listener: (context, state) {
        if (state is! LyricsFetchSuccessState) return;

        final index = _activeIndex ?? 0;

        if (_lyricKeys.isEmpty || index >= _lyricKeys.length) {
          return;
        }

        final context = _lyricKeys[index].currentContext;

        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: 0.35,
          );
        }
      },
      builder: (context, state) {
        if (state is! LyricsFetchSuccessState) {
          if (state is LyricsFetchErrorState) {
            return SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ErrorMessageDialog(
                    message: "Failed to get lyrics for this track.",
                    onRetry: _triggerFetchLyricsEvent,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.expand(child: LoadingIndicator());
        }

        final lyrics = state.lyrics;

        if (_lyricKeys.length != state.lyrics.lines.length) {
          _lyricKeys = List.generate(
            state.lyrics.lines.length,
            (_) => GlobalKey(),
          );
        }

        return SizedBox.expand(
          child: ListView.builder(
            itemCount: lyrics.lines.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.25,
                );
              }

              if (index == lyrics.lines.length + 1) {
                return const SizedBox(height: 200);
              }

              final lyricIndex = index - 1;
              final lyric = lyrics.lines[lyricIndex];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: MusicPlayerLyric(
                  lyric: lyric,
                  allLines: lyrics.lines,
                  index: lyricIndex,
                  lyricKey: _lyricKeys[lyricIndex],
                  activeIndex: _activeIndex ?? 0,
                  onActiveChange: (newActiveIndex) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (!mounted) return;

                      setState(() => _activeIndex = newActiveIndex);

                      final context = _lyricKeys[newActiveIndex].currentContext;

                      if (context != null) {
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          alignment: 0.35,
                        );
                      }
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
