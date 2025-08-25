import "dart:ui";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/parse.dart";

class FloatingMusicPlayerPreview extends StatefulWidget {
  const FloatingMusicPlayerPreview({super.key});

  @override
  State<FloatingMusicPlayerPreview> createState() =>
      _FloatingMusicPlayerPreviewState();
}

class _FloatingMusicPlayerPreviewState
    extends State<FloatingMusicPlayerPreview> {
  Offset? _longPressStart;

  // Range's 0 to 1
  double _trackProgress = 0;
  double _trackProgressAtPressStart = 0;
  // Whether in the mode for the YouTube player to call seekTo()
  bool _isChangingTrackProgress = false;

  void _handleMusicPlayerTrackProgressUpdate(
    LongPressMoveUpdateDetails details,
  ) {
    if (_longPressStart == null) return;

    final dx = details.localPosition.dx - _longPressStart!.dx;

    final width = MediaQuery.of(context).size.width;
    final percentDelta = dx / width; // -1.0 (full left) to +1.0 (full right)

    setState(
      () =>
          _trackProgress = (_trackProgressAtPressStart + percentDelta).clamp(
            0,
            1,
          ),
    );
  }

  void _handleMusicPlayerTrackSeekToUpdate(LongPressEndDetails details) {
    context.read<MusicPlayerPlaystateBloc>().add(
      MusicPlayerPlaystateToggleEvent(),
    );
    setState(() => _isChangingTrackProgress = false);

    final state = context.read<MusicPlayerDurationBloc>().state;
    if (state is! MusicPlayerDurationAvailableState) return;

    final totalSecs = state.totalDuration.inSeconds;
    final newSecs = (_trackProgress * totalSecs).clamp(0, totalSecs);

    context.read<MusicPlayerDurationBloc>().add(
      MusicPlayerDurationSeekToEvent(
        totalDuration: state.totalDuration,
        newDuration: Duration(seconds: newSecs.toInt()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      builder: (context, state) {
        if (state is! MusicPlayerTrackPlayingNowState) return SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push("/playing-now"),
          onLongPressStart:
              (details) => setState(() {
                context.read<MusicPlayerPlaystateBloc>().add(
                  MusicPlayerPlaystateToggleEvent(),
                );
                _isChangingTrackProgress = true;
                _longPressStart = details.localPosition;
                _trackProgressAtPressStart = _trackProgress;
              }),
          onLongPressMoveUpdate: _handleMusicPlayerTrackProgressUpdate,
          onLongPressEnd: _handleMusicPlayerTrackSeekToUpdate,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.shade900,
            ),
            height: 80,
            width: MediaQuery.of(context).size.width - 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // FILLED BACKGROUND
                  BlocConsumer<
                    MusicPlayerDurationBloc,
                    MusicPlayerDurationState
                  >(
                    listener: (context, state) {
                      setState(
                        () =>
                            _trackProgress =
                                state is MusicPlayerDurationAvailableState
                                    ? (state.currentDuration.inSeconds /
                                        state.totalDuration.inSeconds)
                                    : 0.0,
                      );
                    },
                    builder: (context, state) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _trackProgress.clamp(0.0, 1.0),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.white.withAlpha(77),
                                Colors.white.withAlpha(153),
                                Colors.white.withAlpha(77),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(color: Colors.white.withAlpha(26)),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX:
                                5 *
                                (1 - animation.value), // Blur while fading out.
                            sigmaY: 5 * (1 - animation.value),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child:
                        _isChangingTrackProgress
                            ? SizedBox.shrink()
                            : Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: state.playingNowTrack.thumbnail,
                                      fit: BoxFit.cover,
                                      height: 55,
                                      width: 55,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        decodeHtmlSpecialChars(
                                          state.playingNowTrack.title.length >
                                                  22
                                              ? "${state.playingNowTrack.title.substring(0, 22)}..."
                                              : state.playingNowTrack.title,
                                        ),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        state.playingNowTrack.author,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  BlocBuilder<
                                    MusicPlayerDurationBloc,
                                    MusicPlayerDurationState
                                  >(
                                    builder: (context, state) {
                                      if (state
                                          is! MusicPlayerDurationAvailableState) {
                                        return Text(
                                          "00:00",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                          ),
                                        );
                                      }

                                      return Text(
                                        "-${durationify(state.totalDuration - state.currentDuration)}",
                                      );
                                    },
                                  ),
                                  BlocBuilder<
                                    MusicPlayerPlaystateBloc,
                                    MusicPlayerPlaystateState
                                  >(
                                    builder: (context, state) {
                                      return CupertinoButton(
                                        onPressed:
                                            () => context
                                                .read<
                                                  MusicPlayerPlaystateBloc
                                                >()
                                                .add(
                                                  MusicPlayerPlaystateToggleEvent(),
                                                ),
                                        child: Icon(
                                          state
                                                  is MusicPlayerPlaystatePlayingState
                                              ? LucideIcons.pause
                                              : LucideIcons.play,
                                          color: Colors.white,
                                          semanticLabel:
                                              state
                                                      is MusicPlayerPlaystatePlayingState
                                                  ? "Pause"
                                                  : "Play",
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
