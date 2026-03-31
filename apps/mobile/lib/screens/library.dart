import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/bloc/likes/like_count/like_count_bloc.dart";
import "package:wavelength/bloc/likes/like_count/like_count_event.dart";
import "package:wavelength/widgets/action_buttons/downloads_link_button.dart";
import "package:wavelength/widgets/album/album_card.dart";
import "package:wavelength/widgets/artist/artist_tile.dart";
import "package:wavelength/widgets/action_buttons/google_login_button.dart";
import "package:wavelength/widgets/action_buttons/liked_tracks_link_button.dart";
import "package:wavelength/widgets/playlist/playlist_tile.dart";
import "package:wavelength/widgets/skeletons/playlist_tile_skeleton.dart";

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

enum LibraryFilter { playlists, artists, albums }

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryFilter _libraryFilter = LibraryFilter.playlists;
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
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              ChoiceChip(
                                label: const Text("Playlists"),
                                selectedColor: Colors.white,
                                selected:
                                    _libraryFilter == LibraryFilter.playlists,
                                onSelected: (_) => setState(
                                  () =>
                                      _libraryFilter = LibraryFilter.playlists,
                                ),
                              ),
                              const SizedBox(width: 4),
                              ChoiceChip(
                                label: const Text("Artists"),
                                selectedColor: Colors.white,
                                selected:
                                    _libraryFilter == LibraryFilter.artists,
                                onSelected: (_) => setState(
                                  () => _libraryFilter = LibraryFilter.artists,
                                ),
                              ),
                              const SizedBox(width: 4),
                              ChoiceChip(
                                label: const Text("Albums"),
                                selectedColor: Colors.white,
                                selected:
                                    _libraryFilter == LibraryFilter.albums,
                                onSelected: (_) => setState(
                                  () => _libraryFilter = LibraryFilter.albums,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: _libraryFilter == LibraryFilter.playlists,
                            child: Column(
                              children: [
                                const LikedTracksLinkButton(),
                                const DownloadsLinkButton(),
                                for (final playlist in state.playlists)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: PlaylistTile(playlist: playlist),
                                  ),
                              ],
                            ),
                          ),
                          if (_libraryFilter == LibraryFilter.artists)
                            if (state.followedArtists.isEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.2,
                                  ),
                                  const Icon(LucideIcons.disc3, size: 40),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "You are not following any artists.",
                                  ),
                                ],
                              )
                            else
                              for (final artist in state.followedArtists)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: ArtistTile(
                                    browseId: artist.browseId,
                                    title: artist.name,
                                    thumbnail: artist.thumbnail,
                                    subtitle: "Artist",
                                  ),
                                ),
                          if (_libraryFilter == LibraryFilter.albums)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 12.0;
                                final itemWidth =
                                    (constraints.maxWidth - spacing) / 2;

                                if (state.savedAlbums.isEmpty) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                            0.2,
                                      ),
                                      const Icon(
                                        LucideIcons.discAlbum,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text("You have no albums saved."),
                                    ],
                                  );
                                }

                                return Wrap(
                                  spacing: spacing,
                                  children: [
                                    for (final album in state.savedAlbums)
                                      Container(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        width: itemWidth,
                                        child: AlbumCard(
                                          browseId: album.albumId,
                                          cover: album.albumCover,
                                          title: album.title,
                                          albumType: album.albumType,
                                        ),
                                      ),
                                  ],
                                );
                              },
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
