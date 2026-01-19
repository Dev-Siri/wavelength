import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/likes/like_count/like_count_bloc.dart";
import "package:wavelength/bloc/likes/like_count/like_count_state.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class LikedTracksLink extends StatelessWidget {
  const LikedTracksLink({super.key});

  @override
  Widget build(BuildContext context) {
    return AmplButton(
      padding: EdgeInsets.zero,
      onPressed: () => context.push("/likes"),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(140, 42, 155, 1),
                    Color.fromRGBO(87, 137, 199, 1),
                    Color.fromRGBO(83, 150, 237, 1),
                  ],
                ),
              ),
              child: const Icon(
                LucideIcons.hash,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Liked Songs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                BlocBuilder<LikeCountBloc, LikeCountState>(
                  builder: (context, state) {
                    String likeCountText = "Loading...";

                    switch (state) {
                      case LikeCountInitialState _:
                      case LikeCountLoadingState _:
                        break;
                      case LikeCountFetchSuccessState likeCountState:
                        likeCountText =
                            "${likeCountState.likeCount < 1 ? "No" : likeCountState.likeCount} ${likeCountState.likeCount == 1 ? "song" : "songs"}";
                        break;
                      case LikeCountFetchErrorState _:
                        likeCountText = "An error occured";
                        break;
                    }

                    return Text(
                      likeCountText,
                      style: TextStyle(
                        color: state is LikeCountFetchErrorState
                            ? Colors.red
                            : Colors.grey,
                        height: 1,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
