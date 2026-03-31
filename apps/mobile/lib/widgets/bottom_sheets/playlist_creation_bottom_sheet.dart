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
import "package:wavelength/utils/toaster.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class PlaylistCreationBottomSheet extends StatefulWidget {
  const PlaylistCreationBottomSheet({super.key});

  @override
  State<PlaylistCreationBottomSheet> createState() =>
      _PlaylistCreationBottomSheetState();
}

class _PlaylistCreationBottomSheetState
    extends State<PlaylistCreationBottomSheet>
    with Toaster {
  Future<void> _createPlaylist({
    required String userEmail,
    required String authToken,
  }) async {
    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
    final libraryBloc = context.read<LibraryBloc>();

    final response = await PlaylistsRepo.createPlaylist(
      authToken: authToken,
      email: userEmail,
    );

    if (response is ApiResponseSuccess<String>) {
      libraryBloc.add(
        LibraryFetchEvent(email: userEmail, authToken: authToken),
      );
    } else if (mounted) {
      showToast(context, "Something went wrong.", ToastType.error);
    }

    appBottomSheet.add(appBottomSheetCloseEvent);
  }

  @override
  Widget build(BuildContext context) {
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AmplListTile(
                  onTap: () => _createPlaylist(
                    userEmail: state.user.email,
                    authToken: state.authToken,
                  ),
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(LucideIcons.music),
                  title: const Text(
                    "Playlist",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Create an empty playlist.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
