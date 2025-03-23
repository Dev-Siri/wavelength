import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_event.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/playlist_tile.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _publicPlaylistsBloc = PublicPlaylistsBloc();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _publicPlaylistsBloc.add(PublicPlaylistsFetchEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _publicPlaylistsBloc.add(
        PublicPlaylistsFetchEvent(query: query == "" ? null : query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        children: [
          SizedBox(height: 20),
          TextField(
            onChanged: _onSearchChanged,
            style: TextStyle(color: Colors.black),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Search for public playlists...",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w900,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(LucideIcons.compass, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 10),
          BlocConsumer<PublicPlaylistsBloc, PublicPlaylistsState>(
            bloc: _publicPlaylistsBloc,
            listener: (context, state) {},
            builder: (context, state) {
              if (state is! PublicPlaylistsSuccessState) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        for (int i = 0; i < 10; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PlaylistTileSkeleton(),
                          ),
                      ],
                    ),
                    if (state is PublicPlaylistsErrorState)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3.5,
                          ),
                          child: ErrorMessageDialog(
                            message:
                                "Something went wrong while trying to fetch public playlists.",
                          ),
                        ),
                      ),
                  ],
                );
              }

              return Column(
                children: [
                  for (final playlist in state.publicPlaylists)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PlaylistTile(playlist: playlist),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
