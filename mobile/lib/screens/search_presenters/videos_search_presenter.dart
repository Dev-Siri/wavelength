import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";
import "package:wavelength/widgets/video_card.dart";

class VideosSearchPresenter extends StatelessWidget {
  const VideosSearchPresenter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosBloc, VideosState>(
      builder: (context, state) {
        if (state is VideosDefaultState) return const SizedBox();

        if (state is! VideosFetchSuccessState) {
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
              if (state is VideosFetchErrorState)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3.5,
                    ),
                    child: const ErrorMessageDialog(
                      message:
                          "Something went wrong while trying to get YouTube videos.",
                    ),
                  ),
                ),
            ],
          );
        }

        if (state.videos.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 4,
            ),
            child: const Center(
              child: Text(
                "No YouTube videos found for that query.",
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final video in state.videos)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VideoCard(video: video),
              ),
          ],
        );
      },
    );
  }
}
