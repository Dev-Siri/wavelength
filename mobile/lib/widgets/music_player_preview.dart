import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_event.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/music_player_preview_body.dart";

class MusicPlayerPreview extends StatefulWidget {
  const MusicPlayerPreview({super.key});

  @override
  State<MusicPlayerPreview> createState() => _MusicPlayerPreviewState();
}

class _MusicPlayerPreviewState extends State<MusicPlayerPreview> {
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

    final width = MediaQuery.sizeOf(context).width;
    final percentDelta = dx / width; // -1.0 (full left) to +1.0 (full right)

    setState(
      () => _trackProgress = (_trackProgressAtPressStart + percentDelta).clamp(
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
        if (state is MusicPlayerTrackEmptyState) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push("/playing-now"),
          onLongPressStart: (details) => setState(() {
            context.read<MusicPlayerPlaystateBloc>().add(
              MusicPlayerPlaystateToggleEvent(),
            );
            _isChangingTrackProgress = true;
            _longPressStart = details.localPosition;
            _trackProgressAtPressStart = _trackProgress;
          }),
          onLongPressMoveUpdate: _handleMusicPlayerTrackProgressUpdate,
          onLongPressEnd: _handleMusicPlayerTrackSeekToUpdate,
          child: Hero(
            tag: "music-player-preview",
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.grey.shade900,
              ),
              height: 60,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    // FILLED BACKGROUND
                    BlocConsumer<
                      MusicPlayerDurationBloc,
                      MusicPlayerDurationState
                    >(
                      listener: (context, state) => setState(
                        () => _trackProgress =
                            state is MusicPlayerDurationAvailableState
                            ? (state.currentDuration.inSeconds /
                                  state.totalDuration.inSeconds)
                            : 0.0,
                      ),
                      builder: (context, state) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _trackProgress.clamp(0.0, 1.0),
                          child: Container(color: Colors.white.withAlpha(26)),
                        );
                      },
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _isChangingTrackProgress
                          ? const SizedBox.shrink()
                          : state is! MusicPlayerTrackPlayingNowState
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : MusicPlayerPreviewBody(
                              playingNowTrack: state.playingNowTrack,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
