import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/search/albums/albums_bloc.dart";
import "package:wavelength/bloc/search/albums/albums_state.dart";
import "package:wavelength/widgets/album_card.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class AlbumsSearchPresenter extends StatelessWidget {
  const AlbumsSearchPresenter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumsBloc, AlbumsState>(
      builder: (context, state) {
        if (state is AlbumsDefaultState) return const SizedBox();

        if (state is! AlbumsFetchSuccessState) {
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
              if (state is AlbumsFetchErrorState)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.sizeOf(context).height / 3.5,
                    ),
                    child: const ErrorMessageDialog(
                      message:
                          "Something went wrong while trying to get albums.",
                    ),
                  ),
                ),
            ],
          );
        }

        if (state.albums.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height / 4,
            ),
            child: const Center(
              child: Text(
                "No Album found for that query.",
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final album in state.albums)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AlbumCard(album: album),
              ),
          ],
        );
      },
    );
  }
}
