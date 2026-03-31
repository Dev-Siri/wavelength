import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/lyrics_line.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/constants.dart";

class MusicPlayerLyricLine extends StatelessWidget {
  final List<Syllable> syllables;
  final List<Syllable> backgroundSyllables;
  final bool isActive;
  final int lineIndex;
  final List<LyricsLine> allLines;
  final String? romanizedText;

  const MusicPlayerLyricLine({
    super.key,
    required this.syllables,
    required this.backgroundSyllables,
    required this.isActive,
    required this.allLines,
    required this.lineIndex,
    required this.romanizedText,
  });

  bool _isInstrumentalGap() {
    if (lineIndex == 0) {
      return allLines[0].endtime >= instrumentalThreshold;
    }

    final prev = allLines[lineIndex - 1];
    final curr = allLines[lineIndex];

    final gap = curr.timestamp - prev.endtime;

    return gap >= instrumentalThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      offset: Offset(isActive ? 0.01 : 0, isActive ? 0 : 0.1),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        scale: isActive ? 1.02 : 0.95,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isActive ? 1 : 0.5,
          child: BlocBuilder<MusicPlayerDurationBloc, MusicPlayerDurationState>(
            builder: (context, state) {
              if (state is! MusicPlayerDurationAvailableState) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _isInstrumentalGap()
                        ? Builder(
                            builder: (_) {
                              final now = state.currentDuration.inMilliseconds;

                              final prev = lineIndex == 0
                                  ? null
                                  : allLines[lineIndex - 1];
                              final curr = allLines[lineIndex];

                              final gapStart = lineIndex == 0
                                  ? 0
                                  : prev!.endtime;
                              final gapEnd = curr.timestamp;

                              if (now < gapStart || now > gapEnd) {
                                return const SizedBox(key: ValueKey("no-dots"));
                              }

                              final gapDuration = gapEnd - gapStart;
                              final segment = gapDuration / 3;

                              final progress = (now - gapStart) / segment;
                              final currentDot = progress.floor() % 3;
                              return Padding(
                                key: const ValueKey("dots"),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(3, (i) {
                                    final isActiveDot = i == currentDot;

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      margin: const EdgeInsets.only(right: 12),
                                      width: isActiveDot ? 14 : 12,
                                      height: isActiveDot ? 14 : 12,
                                      decoration: BoxDecoration(
                                        color: isActiveDot
                                            ? Colors.white
                                            : Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          )
                        : const SizedBox(key: ValueKey("no-dots")),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: syllables.map((s) {
                            final isActiveWord =
                                state.currentDuration.inMilliseconds >=
                                    s.timestamp &&
                                state.currentDuration.inMilliseconds <=
                                    s.endtime;
                            final isPastWord =
                                state.currentDuration.inMilliseconds >
                                s.endtime;

                            return WidgetSpan(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 26,
                                  letterSpacing: -0.8,
                                  fontWeight: FontWeight.bold,
                                  color: isActiveWord
                                      ? Colors.white
                                      : isPastWord
                                      ? Colors.white70
                                      : Colors.white30,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(s.text),
                                    if (s.romanizedText != null)
                                      Text(
                                        s.romanizedText!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white60,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (backgroundSyllables.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            children: backgroundSyllables.map((s) {
                              final isActiveWord =
                                  state.currentDuration.inMilliseconds >=
                                      s.timestamp &&
                                  state.currentDuration.inMilliseconds <=
                                      s.endtime;
                              final isPastWord =
                                  state.currentDuration.inMilliseconds >
                                  s.endtime;

                              return WidgetSpan(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 22,
                                    letterSpacing: -0.8,
                                    fontWeight: FontWeight.bold,
                                    color: isActiveWord
                                        ? Colors.white70
                                        : isPastWord
                                        ? Colors.white38
                                        : Colors.white24,
                                  ),
                                  child: Text(s.text),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
