import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/playlist/playlist_bloc.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/widgets/confirmation_dialog.dart";

class PlaylistTrackTileOptionsBottomSheet extends StatelessWidget {
  final String playlistId;
  final VideoType videoType;
  final Track track;

  const PlaylistTrackTileOptionsBottomSheet({
    super.key,
    required this.playlistId,
    required this.videoType,
    required this.track,
  });

  Future<void> _removeTrackFromPlaylist(BuildContext context) async {
    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
    final messenger = ScaffoldMessenger.of(context);
    final playlistBloc = context.read<PlaylistBloc>();

    final trackToggleResponse = await TrackRepo.toggleTrackFromPlaylist(
      playlistId: playlistId,
      videoType: videoType,
      track: track,
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

    playlistBloc.add(PlaylistFetchEvent(playlistId: playlistId));
  }

  void _handleTileTap(BuildContext context) => showAdaptiveDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      onConfirm: () => _removeTrackFromPlaylist(context),
      title: "Remove '${track.title}' ?",
      content: "This action will remove the song from this playlist.",
    ),
  );

  @override
  Widget build(BuildContext context) {
    final title = const Text(
      "Remove from playlist.",
      style: TextStyle(color: Colors.red),
    );
    final leading = const Icon(LucideIcons.trash, color: Colors.red);

    return Container(
      height: MediaQuery.of(context).size.height * 0.12, // 12% of the screen
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Platform.isIOS
                ? CupertinoListTile(
                    onTap: () => _handleTileTap(context),
                    leading: leading,
                    padding: const EdgeInsets.all(20),
                    title: title,
                  )
                : ListTile(
                    onTap: () => _handleTileTap(context),
                    leading: leading,
                    title: title,
                  ),
          ),
        ],
      ),
    );
  }
}
