import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";
import "package:wavelength/widgets/track_tile.dart";

class TracksSearchPresenter extends StatelessWidget {
  const TracksSearchPresenter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TracksBloc, TracksState>(
      builder: (context, state) {
        if (state is TracksDefaultState) return SizedBox();

        if (state is! TracksFetchSuccessState) {
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
              if (state is TracksFetchErrorState)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3.5,
                    ),
                    child: ErrorMessageDialog(
                      message:
                          "Something went wrong while trying to get songs.",
                    ),
                  ),
                ),
            ],
          );
        }

        if (state.tracks.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 4,
            ),
            child: Center(
              child: Text(
                "No match found for that query.",
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final track in state.tracks)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TrackTile(track: track),
              ),
          ],
        );
      },
    );
  }
}
