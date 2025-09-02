import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/widgets/confirmation_dialog.dart";

class PlaylistTile extends StatefulWidget {
  final Playlist playlist;

  const PlaylistTile({super.key, required this.playlist});

  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  Future<void> _deletePlaylist({required String userEmail}) async {
    final messenger = ScaffoldMessenger.of(context);
    final libraryBloc = context.read<LibraryBloc>();

    final response = await PlaylistsRepo.deletePlaylist(
      playlistId: widget.playlist.playlistId,
    );

    if (response.success) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text(
            "Playlist deleted successfully!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      libraryBloc.add(LibraryPlaylistsFetchEvent(email: userEmail));
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: const Text(
          "Failed to delete playlist.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget innerUi = Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          if (widget.playlist.coverImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: widget.playlist.coverImage!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.playlist.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.playlist.authorName,
                style: TextStyle(color: Colors.grey, height: 1, fontSize: 14),
              ),
            ],
          ),
          Spacer(),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(LucideIcons.trash2, color: Colors.red),
                onPressed: () => state is AuthStateAuthorized
                    ? showDialog(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          onConfirm: () =>
                              _deletePlaylist(userEmail: state.user.email),
                          title: "Delete '${widget.playlist.name}' ?",
                          content: "This action cannot be undone.",
                        ),
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade900,
        onPressed: () =>
            context.push("/playlist/${widget.playlist.playlistId}"),
        child: innerUi,
      );
    } else {
      return MaterialButton(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.grey.shade900,
        onPressed: () =>
            context.push("/playlist/${widget.playlist.playlistId}"),
        child: innerUi,
      );
    }
  }
}
