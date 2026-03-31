import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/utils/toaster.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class PlaylistVisibilityToggle extends StatefulWidget {
  final String playlistId;
  final bool isInitiallyPrivate;

  const PlaylistVisibilityToggle({
    super.key,
    required this.playlistId,
    required this.isInitiallyPrivate,
  });

  @override
  State<PlaylistVisibilityToggle> createState() =>
      _PlaylistVisibilityToggleState();
}

class _PlaylistVisibilityToggleState extends State<PlaylistVisibilityToggle>
    with Toaster {
  bool _isLoading = false;
  bool _isPrivate = true;

  @override
  void initState() {
    super.initState();
    setState(() => _isPrivate = widget.isInitiallyPrivate);
  }

  Future<void> _toggleVisibilityPlaylist(String authToken) async {
    setState(() => _isLoading = true);

    final response = await PlaylistsRepo.togglePlaylistVisibility(
      playlistId: widget.playlistId,
      authToken: authToken,
    );

    if (response is ApiResponseSuccess) {
      setState(() {
        _isLoading = false;
        _isPrivate = !_isPrivate;
      });
      return;
    }

    if (mounted) {
      showToast(context, "Something went wrong.", ToastType.error);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthStateAuthorized) {
          return const SizedBox.shrink();
        }

        return AmplIconButton(
          color: Colors.grey.shade800,
          padding: EdgeInsets.zero,
          onPressed: () => _toggleVisibilityPlaylist(state.authToken),
          disabled: _isLoading,
          icon: Icon(
            _isPrivate ? LucideIcons.lock : LucideIcons.globe,
            size: 20,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
