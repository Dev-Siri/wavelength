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
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_state.dart";

class AddToPlaylistBottomSheet extends StatelessWidget {
  final Track track;
  final VideoType videoType;

  const AddToPlaylistBottomSheet({
    super.key,
    required this.track,
    required this.videoType,
  });

  Future<void> _toggleTrackFromPlaylist(
    BuildContext context,
    String playlistId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);

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
              : "An error occured while adding track to the playlist.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is! LibraryFetchSuccessState) return SizedBox.shrink();

        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.4, // 40% of the screen's height.
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: state.playlists.map((playlist) {
              final title = Text(
                playlist.name,
                style: TextStyle(color: Colors.white),
              );
              final subtitle = Text(
                "Add to this playlist.",
                style: TextStyle(color: Colors.grey.shade600),
              );

              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Platform.isIOS
                    ? CupertinoListTile(
                        onTap: () => _toggleTrackFromPlaylist(
                          context,
                          playlist.playlistId,
                        ),
                        leading: Icon(LucideIcons.listMusic),
                        padding: EdgeInsets.all(20),
                        title: title,
                        subtitle: subtitle,
                      )
                    : ListTile(
                        onTap: () => _toggleTrackFromPlaylist(
                          context,
                          playlist.playlistId,
                        ),
                        leading: Icon(LucideIcons.listMusic),
                        title: title,
                        subtitle: subtitle,
                      ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
