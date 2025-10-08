import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_state.dart";
import "package:wavelength/widgets/artist_card.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class ArtistsSearchPresenter extends StatelessWidget {
  const ArtistsSearchPresenter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistsBloc, ArtistsState>(
      builder: (context, state) {
        if (state is ArtistsDefaultState) return const SizedBox();

        if (state is! ArtistsFetchSuccessState) {
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
              if (state is ArtistsFetchErrorState)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3.5,
                    ),
                    child: const ErrorMessageDialog(
                      message:
                          "Something went wrong while trying to get artists.",
                    ),
                  ),
                ),
            ],
          );
        }

        if (state.artists.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 4,
            ),
            child: const Center(
              child: Text(
                "No match found for that query.",
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final artist in state.artists)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ArtistCard(artist: artist),
              ),
          ],
        );
      },
    );
  }
}
