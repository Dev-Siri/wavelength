import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:hive_flutter/hive_flutter.dart";
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
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class AddToPlaylistBottomSheet extends StatefulWidget {
  final Track track;
  final VideoType videoType;

  const AddToPlaylistBottomSheet({
    super.key,
    required this.track,
    required this.videoType,
  });

  @override
  State<AddToPlaylistBottomSheet> createState() =>
      _AddToPlaylistBottomSheetState();
}

class _AddToPlaylistBottomSheetState extends State<AddToPlaylistBottomSheet> {
  bool _isTrackDownloaded = false;

  @override
  void initState() {
    _fetchTrackAlreadyDownloaded();
    super.initState();
  }

  Future<void> _toggleTrackFromPlaylist(
    BuildContext context,
    String playlistId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);

    int duration = widget.track.duration;

    if (duration == 0) {
      final durationResponse = await TrackRepo.fetchTrackDuration(
        trackId: widget.track.videoId,
      );

      if (durationResponse is! ApiResponseSuccess<int>) return;

      duration = durationResponse.data;
    }

    final trackToggleResponse = await TrackRepo.toggleTrackFromPlaylist(
      playlistId: playlistId,
      videoType: widget.videoType,
      track: Track(
        videoId: widget.track.videoId,
        album: widget.track.album,
        artists: widget.track.artists,
        duration: duration,
        isExplicit: widget.track.isExplicit,
        thumbnail: widget.track.thumbnail,
        title: widget.track.title,
      ),
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
              : "An error occured while adding track to the playlist.",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _fetchTrackAlreadyDownloaded() async {
    final exists = await AudioCache.exists(widget.track.videoId);
    setState(() => _isTrackDownloaded = exists);
  }

  Future<void> _downloadTrack() async {
    if (_isTrackDownloaded) {
      await AudioCache.deleteTrack(widget.track.videoId);
      final box = await Hive.openBox(hiveStreamsKey);
      await box.delete(widget.track.videoId);

      setState(() => _isTrackDownloaded = false);
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
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

    context.read<AppBottomSheetBloc>().add(
      AppBottomSheetCloseEvent(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.track.album;

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is! LibraryFetchSuccessState) return const SizedBox.shrink();

        return Container(
          height:
              MediaQuery.sizeOf(context).height *
              0.8, // 40% of the screen's height.
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20),
                  child: Text(
                    "Download",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AmplListTile(
                    onTap: _downloadTrack,
                    leading: const Icon(LucideIcons.album),
                    padding: const EdgeInsets.all(20),
                    title: Text(
                      _isTrackDownloaded ? "Remove save." : "Save offline",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (album != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 10,
                      left: 20,
                    ),
                    child: Text(
                      "Song Album",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (album != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AmplListTile(
                      onTap: () {
                        context.read<AppBottomSheetBloc>().add(
                          AppBottomSheetCloseEvent(context: context),
                        );
                        context.push("/album/${album.browseId}");
                      },
                      leading: const Icon(LucideIcons.album),
                      padding: const EdgeInsets.all(20),
                      title: Text(
                        album.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20),
                  child: Text(
                    "View ${widget.track.artists.length == 1 ? "Artist" : "Artists"}",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...widget.track.artists.map((artist) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AmplListTile(
                      onTap: () {
                        context.read<AppBottomSheetBloc>().add(
                          AppBottomSheetCloseEvent(context: context),
                        );
                        context.push("/artist/${artist.browseId}");
                      },
                      leading: const Icon(LucideIcons.circleUser),
                      padding: const EdgeInsets.all(20),
                      title: Text(
                        artist.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20),
                  child: Text(
                    "Add ${widget.track.title} To Your Playlists",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...state.playlists.map((playlist) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AmplListTile(
                      onTap: () => _toggleTrackFromPlaylist(
                        context,
                        playlist.playlistId,
                      ),
                      leading: const Icon(LucideIcons.listMusic),
                      padding: const EdgeInsets.all(20),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Add to this playlist.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
