import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";

class PlaylistCreationBottomSheet extends StatefulWidget {
  const PlaylistCreationBottomSheet({super.key});

  @override
  State<PlaylistCreationBottomSheet> createState() =>
      _PlaylistCreationBottomSheetState();
}

class _PlaylistCreationBottomSheetState
    extends State<PlaylistCreationBottomSheet> {
  Future<void> _createPlaylist({
    required String userEmail,
    required String username,
    required String userImage,
  }) async {
    final navigator = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final libraryBloc = context.read<LibraryBloc>();

    final response = await PlaylistsRepo.createPlaylist(
      email: userEmail,
      image: userImage,
      username: username,
    );

    if (response.success) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text(
            "Playlist created successfully!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      libraryBloc.add(LibraryPlaylistsFetchEvent(email: userEmail));
    } else {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text(
            "Something went wrong.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = Text("Playlist", style: TextStyle(color: Colors.white));
    final subtitle = Text(
      "Create an empty playlist.",
      style: TextStyle(color: Colors.grey.shade600),
    );

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthStateAuthorized) {
          return SizedBox();
        }

        return Container(
          height: 80,
          width: double.infinity,
          margin: Platform.isIOS
              ? EdgeInsets.only(bottom: 20)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Platform.isIOS
                    ? CupertinoListTile(
                        onTap: () => _createPlaylist(
                          userEmail: state.user.email,
                          username: state.user.displayName ?? "",
                          userImage: state.user.photoUrl ?? "",
                        ),
                        leading: Icon(LucideIcons.listMusic),
                        padding: EdgeInsets.all(20),
                        title: title,
                        subtitle: subtitle,
                      )
                    : ListTile(
                        onTap: () => _createPlaylist(
                          userEmail: state.user.email,
                          username: state.user.displayName ?? "",
                          userImage: state.user.photoUrl ?? "",
                        ),
                        leading: Icon(LucideIcons.listMusic),
                        title: title,
                        subtitle: subtitle,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
