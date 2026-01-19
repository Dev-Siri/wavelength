import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/bloc/likes/like_count/like_count_bloc.dart";
import "package:wavelength/bloc/likes/like_count/like_count_event.dart";
import "package:wavelength/widgets/followed_artists_carousel.dart";
import "package:wavelength/widgets/google_login_button.dart";
import "package:wavelength/widgets/liked_tracks_link.dart";
import "package:wavelength/widgets/playlist_tile.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _refreshLibrary(
    BuildContext context, {
    required String email,
    required String authToken,
  }) {
    context.read<LibraryBloc>().add(
      LibraryFetchEvent(email: email, authToken: authToken),
    );
    context.read<LikeCountBloc>().add(
      LikeCountFetchEvent(authToken: authToken),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return RefreshIndicator.adaptive(
          color: Colors.white,
          onRefresh: () async => state is AuthStateAuthorized
              ? _refreshLibrary(
                  context,
                  email: state.user.email,
                  authToken: state.authToken,
                )
              : null,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Your Library",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthStateUnauthorized) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Please login to view your library and create playlists.",
                        ),
                        SizedBox(height: 15),
                        GoogleLoginButton(),
                      ],
                    );
                  }

                  return BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      if (state is! LibraryFetchSuccessState) {
                        return Column(
                          children: [
                            for (int i = 0; i < 6; i++)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: PlaylistTileSkeleton(),
                              ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          FollowedArtistsCarousel(
                            follows: state.followedArtists,
                          ),
                          const LikedTracksLink(),
                          for (final playlist in state.playlists)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: PlaylistTile(playlist: playlist),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
