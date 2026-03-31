import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/lyrics_line.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/widgets/music_player/music_player_lyric_line.dart";

class MusicPlayerLyric extends StatefulWidget {
  final GlobalKey<State<StatefulWidget>> lyricKey;
  final LyricsLine lyric;
  final List<LyricsLine> allLines;
  final int index;
  final int activeIndex;
  final Function(int newActiveIndex) onActiveChange;

  const MusicPlayerLyric({
    super.key,
    required this.lyricKey,
    required this.allLines,
    required this.lyric,
    required this.index,
    required this.activeIndex,
    required this.onActiveChange,
  });

  @override
  State<MusicPlayerLyric> createState() => _MusicPlayerLyricState();
}

class _MusicPlayerLyricState extends State<MusicPlayerLyric> {
  bool _isLyricInFocus(
    MusicPlayerDurationAvailableState state,
    LyricsLine lyric,
  ) {
    return state.currentDuration.inMilliseconds > lyric.timestamp &&
        state.currentDuration.inMilliseconds < lyric.endtime;
  }

  Color _getLyricTextColor(
    MusicPlayerDurationAvailableState state,
    LyricsLine lyric,
  ) {
    final isLyricFocused = _isLyricInFocus(state, lyric);

    if (isLyricFocused) {
      return Colors.white;
    } else if (state.currentDuration.inMilliseconds > lyric.timestamp) {
      return Colors.white.withAlpha(180);
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerDurationBloc, MusicPlayerDurationState>(
      builder: (context, state) {
        final isProgressStateAvailable =
            state is MusicPlayerDurationAvailableState;
        final lyricTextColor = isProgressStateAvailable
            ? _getLyricTextColor(state, widget.lyric)
            : Colors.grey;

        final musicPlayerDurationBloc = context.read<MusicPlayerDurationBloc>();
        final musicPlayerDurationState = musicPlayerDurationBloc.state;

        final isActive =
            isProgressStateAvailable && _isLyricInFocus(state, widget.lyric);

        if (isActive && widget.activeIndex != widget.index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onActiveChange(widget.index);
          });
        }

        return KeyedSubtree(
          key: widget.lyricKey,
          child: GestureDetector(
            onTap: () => musicPlayerDurationBloc.add(
              MusicPlayerDurationSeekToEvent(
                totalDuration:
                    musicPlayerDurationState
                        is MusicPlayerDurationAvailableState
                    ? musicPlayerDurationState.totalDuration
                    : Duration.zero,
                newDuration: Duration(milliseconds: widget.lyric.timestamp),
              ),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: lyricTextColor,
              ),
              child: MusicPlayerLyricLine(
                syllables: widget.lyric.text ?? [],
                backgroundSyllables: widget.lyric.backgroundText ?? [],
                romanizedText: widget.lyric.romanizedText,
                isActive: isActive,
                allLines: widget.allLines,
                lineIndex: widget.index,
              ),
            ),
          ),
        );
      },
    );
  }
}
