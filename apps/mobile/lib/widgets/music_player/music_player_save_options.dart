import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/bottom_sheets/track_options_bottom_sheet.dart";
import "package:wavelength/widgets/track/track_like_button.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class MusicPlayerSaveOptions extends StatelessWidget {
  const MusicPlayerSaveOptions({super.key});

  void _openAddToPlaylistOptions(BuildContext context, QueueableMusic track) =>
      context.read<AppBottomSheetBloc>().add(
        AppBottomSheetOpenEvent(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => TrackOptionsBottomSheet(
            track: Track(
              videoId: track.videoId,
              title: track.title,
              thumbnail: track.thumbnail,
              artists: track.artists,
              duration: track.duration,
              isExplicit: track.isExplicit,
              album: track.album,
            ),
            videoType: track.videoType,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
          builder: (context, state) {
            if (state is! MusicPlayerTrackPlayingNowState) {
              return const SizedBox.shrink();
            }

            return TrackLikeButton(
              size: 20,
              track: Track(
                title: state.playingNowTrack.title,
                album: state.playingNowTrack.album,
                artists: state.playingNowTrack.artists,
                duration: 0,
                isExplicit: state.playingNowTrack.isExplicit,
                thumbnail: state.playingNowTrack.thumbnail,
                videoId: state.playingNowTrack.videoId,
              ),
              videoType: state.playingNowTrack.videoType,
            );
          },
        ),
        BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
          builder: (context, state) {
            if (state is! MusicPlayerTrackPlayingNowState) {
              return const SizedBox.shrink();
            }

            return AmplIconButton(
              icon: const Icon(LucideIcons.circlePlus),
              onPressed: () =>
                  _openAddToPlaylistOptions(context, state.playingNowTrack),
            );
          },
        ),
      ],
    );
  }
}
