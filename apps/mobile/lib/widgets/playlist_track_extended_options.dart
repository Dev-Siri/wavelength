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
import "package:wavelength/utils/toaster.dart";
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
    extends State<PlaylistTrackExtendedOptions>
    with Toaster {
  Future<void> _removeTrackFromPlaylist() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthStateAuthorized) return;

    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
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

    if (mounted) {
      showToast(
        context,
        isResponseSuccessful
            ? trackToggleResponse.data
            : "An error occured while removing track from the playlist.",
        isResponseSuccessful ? ToastType.success : ToastType.error,
      );
    }

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        onTap: _handleRemoveTileTap,
        leading: Icon(LucideIcons.circleMinus, color: Colors.red.shade400),
        title: Text(
          "Remove from playlist.",
          style: TextStyle(color: Colors.red.shade400),
        ),
      ),
    );
  }
}
