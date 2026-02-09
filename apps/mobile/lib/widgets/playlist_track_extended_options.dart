import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/playlist/playlist_bloc.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/widgets/confirmation_dialog.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class PlaylistTrackExtendedOptions extends StatefulWidget {
  final String playlistId;
  final VideoType videoType;
  final Track track;

  const PlaylistTrackExtendedOptions({
    super.key,
    required this.playlistId,
    required this.videoType,
    required this.track,
  });

  @override
  State<PlaylistTrackExtendedOptions> createState() =>
      _PlaylistTrackExtendedOptionsState();
}

class _PlaylistTrackExtendedOptionsState
    extends State<PlaylistTrackExtendedOptions> {
  Future<void> _removeTrackFromPlaylist() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthStateAuthorized) return;

    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
    final messenger = ScaffoldMessenger.of(context);
    final playlistBloc = context.read<PlaylistBloc>();

    final trackToggleResponse = await TrackRepo.toggleTrackFromPlaylist(
      playlistId: widget.playlistId,
      videoType: widget.videoType,
      track: widget.track,
      authToken: authState.authToken,
    );
    final isResponseSuccessful =
        trackToggleResponse is ApiResponseSuccess<String>;

    appBottomSheet.add(appBottomSheetCloseEvent);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: isResponseSuccessful ? Colors.green : Colors.red,
        content: Text(
          isResponseSuccessful
              ? trackToggleResponse.data
              : "An error occured while removing track from the playlist.",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );

    playlistBloc.add(PlaylistFetchEvent(playlistId: widget.playlistId));
  }

  void _handleRemoveTileTap() => showAdaptiveDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      onConfirm: _removeTrackFromPlaylist,
      title: "Remove '${widget.track.title}' ?",
      content: "This action will remove the song from this playlist.",
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AmplListTile(
        onTap: _handleRemoveTileTap,
        leading: const Icon(LucideIcons.trash, color: Colors.red),
        padding: const EdgeInsets.all(20),
        title: const Text(
          "Remove from playlist.",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
