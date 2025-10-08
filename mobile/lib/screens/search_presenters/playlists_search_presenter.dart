import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_event.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/playlist_tile.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class PlaylistsSearchPresenter extends StatefulWidget {
  const PlaylistsSearchPresenter({super.key});

  @override
  State<PlaylistsSearchPresenter> createState() =>
      _PlaylistsSearchPresenterState();
}

class _PlaylistsSearchPresenterState extends State<PlaylistsSearchPresenter> {
  @override
  void initState() {
    context.read<PublicPlaylistsBloc>().add(PublicPlaylistsFetchEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicPlaylistsBloc, PublicPlaylistsState>(
      builder: (context, state) {
        if (state is! PublicPlaylistsSuccessState) {
          return Stack(
            children: [
              Column(
                children: [
                  for (int i = 0; i < 10; i++)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
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
                    child: const ErrorMessageDialog(
                      message:
                          "Something went wrong while trying to fetch public playlists.",
                    ),
                  ),
                ),
            ],
          );
        }

        if (state.publicPlaylists.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 4,
            ),
            child: const Center(
              child: Text(
                "No public playlists available.",
                style: TextStyle(fontSize: 20),
              ),
            ),
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
    );
  }
}
