import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class MusicPlayerPresenceAdjuster extends StatelessWidget {
  final Widget child;

  const MusicPlayerPresenceAdjuster({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: state is MusicPlayerTrackPlayingNowState ? 85 : 0,
          ),
          child: child,
        );
      },
    );
  }
}
