import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

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
    required String authToken,
  }) async {
    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
    final messenger = ScaffoldMessenger.of(context);
    final libraryBloc = context.read<LibraryBloc>();

    final response = await PlaylistsRepo.createPlaylist(
      authToken: authToken,
      email: userEmail,
    );

    if (response is ApiResponseSuccess<String>) {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Playlist created successfully!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      libraryBloc.add(
        LibraryFetchEvent(email: userEmail, authToken: authToken),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Something went wrong.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    appBottomSheet.add(appBottomSheetCloseEvent);
  }

  @override
  Widget build(BuildContext context) {
    final title = const Text("Playlist", style: TextStyle(color: Colors.white));
    final subtitle = Text(
      "Create an empty playlist.",
      style: TextStyle(color: Colors.grey.shade600),
    );

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthStateAuthorized) {
          return const SizedBox();
        }

        return Container(
          height: 80,
          width: double.infinity,
          margin: Platform.isIOS
              ? const EdgeInsets.only(bottom: 20)
              : EdgeInsets.zero,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: AmplListTile(
                  onTap: () => _createPlaylist(
                    userEmail: state.user.email,
                    authToken: state.authToken,
                  ),
                  leading: const Icon(LucideIcons.listMusic),
                  padding: const EdgeInsets.all(20),
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
