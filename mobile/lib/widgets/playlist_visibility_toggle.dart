import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";

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

class _PlaylistVisibilityToggleState extends State<PlaylistVisibilityToggle> {
  bool _isLoading = false;
  bool _isPrivate = true;

  @override
  void initState() {
    setState(() => _isPrivate = widget.isInitiallyPrivate);
    super.initState();
  }

  Future<void> _toggleVisibilityPlaylist() async {
    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);

    final response = await PlaylistsRepo.togglePlaylistVisibility(
      playlistId: widget.playlistId,
    );

    if (response is ApiResponseSuccess) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            "Changed visibility of playlist to ${_isPrivate ? "public" : "private"}.",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
        _isPrivate = !_isPrivate;
      });
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "An error occured while changing visibility.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final innerUi = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          _isPrivate ? LucideIcons.lock : LucideIcons.globe,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        Text(
          _isPrivate ? "Private" : "Public",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        color: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        onPressed: _isLoading ? null : _toggleVisibilityPlaylist,
        child: innerUi,
      );
    }

    return MaterialButton(
      color: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      onPressed: _isLoading ? null : _toggleVisibilityPlaylist,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      child: innerUi,
    );
  }
}
