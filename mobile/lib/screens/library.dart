import "package:flutter/cupertino.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/widgets/google_login_button.dart";
import "package:wavelength/widgets/playlist_tile.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("Your Library", style: TextStyle(fontSize: 30)),
          ),
          SizedBox(height: 10),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthStateUnauthorized) {
                return Column(
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
                        for (int i = 0; i < 10; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: PlaylistTileSkeleton(),
                          ),
                      ],
                    );
                  }

                  return Column(
                    children: [
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
  }
}
