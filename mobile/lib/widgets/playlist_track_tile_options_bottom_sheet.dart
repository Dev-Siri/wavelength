import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:uuid/v4.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/stream_download.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/playlist/playlist_bloc.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/widgets/confirmation_dialog.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class PlaylistTrackTileOptionsBottomSheet extends StatefulWidget {
  final String playlistId;
  final VideoType videoType;
  final Track track;

  const PlaylistTrackTileOptionsBottomSheet({
    super.key,
    required this.playlistId,
    required this.videoType,
    required this.track,
  });

  @override
  State<PlaylistTrackTileOptionsBottomSheet> createState() =>
      _PlaylistTrackTileOptionsBottomSheetState();
}

class _PlaylistTrackTileOptionsBottomSheetState
    extends State<PlaylistTrackTileOptionsBottomSheet> {
  bool _trackAlreadyDownloaded = false;

  Future<void> _removeTrackFromPlaylist() async {
    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
    final messenger = ScaffoldMessenger.of(context);
    final playlistBloc = context.read<PlaylistBloc>();

    final trackToggleResponse = await TrackRepo.toggleTrackFromPlaylist(
      playlistId: widget.playlistId,
      videoType: widget.videoType,
      track: widget.track,
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

  Future<void> _handleDownloadCacheTileTap(BuildContext context) async {
    if (_trackAlreadyDownloaded) {
      await AudioCache.deleteTrack(widget.track.videoId);
      setState(() => _trackAlreadyDownloaded = false);
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        backgroundColor: Colors.blue,
        content: Text("Saving track...", style: TextStyle(color: Colors.white)),
      ),
    );

    context.read<DownloadBloc>().add(
      DownloadAddToQueueEvent(
        newDownload: StreamDownload(
          downloadId: const UuidV4().generate(),
          metadata: widget.track,
        ),
      ),
    );

    navigator.pop();
  }

  Future<void> _fetchTrackAlreadyDownloaded() async {
    final exists = await AudioCache.exists(widget.track.videoId);
    setState(() => _trackAlreadyDownloaded = exists);
  }

  @override
  void initState() {
    _fetchTrackAlreadyDownloaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.20, // 20% of the screen
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ClipRRect(
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
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AmplListTile(
              onTap: () => _handleDownloadCacheTileTap(context),
              leading: Icon(
                LucideIcons.cloudDownload,
                color: _trackAlreadyDownloaded ? Colors.red : Colors.white,
              ),
              padding: Platform.isIOS
                  ? const EdgeInsets.all(20)
                  : EdgeInsets.zero,
              title: Text(
                _trackAlreadyDownloaded ? "Remove save." : "Save offline.",
                style: TextStyle(
                  color: _trackAlreadyDownloaded ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
