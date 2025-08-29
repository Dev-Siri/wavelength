import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/app_shell.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_bloc.dart";
import "package:wavelength/screens/artist.dart";
import "package:wavelength/screens/home.dart";
import "package:wavelength/screens/library.dart";
import "package:wavelength/screens/explore.dart";
import "package:wavelength/screens/playing_now.dart";
import "package:wavelength/screens/playlist.dart";
import "package:wavelength/transitions.dart";
import "package:wavelength/widgets/floating_music_player_preview.dart";
import "package:wavelength/widgets/music_player_internals.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        ShellRoute(
          routes: [
            GoRoute(path: "/", builder: (_, __) => HomeScreen()),
            GoRoute(
              path: "/explore",
              builder: (_, __) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => PublicPlaylistsBloc()),
                  BlocProvider(create: (_) => TracksBloc()),
                  BlocProvider(create: (_) => VideosBloc()),
                  BlocProvider(create: (_) => ArtistsBloc()),
                ],
                child: ExploreScreen(),
              ),
            ),
            GoRoute(path: "/library", builder: (_, __) => LibraryScreen()),
          ],
          builder: (_, __, child) {
            return AppShell(child: child);
          },
        ),
        GoRoute(
          path: "/playlist/:id",
          pageBuilder: (_, state) {
            final id = state.pathParameters["id"]!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: PlaylistScreen(playlistId: id),
              transitionsBuilder: pageSlideUpTransition,
            );
          },
        ),
        GoRoute(
          path: "/artist/:id",
          pageBuilder: (_, state) {
            final id = state.pathParameters["id"]!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: ArtistScreen(browseId: id),
              transitionsBuilder: pageSlideUpTransition,
            );
          },
        ),
        GoRoute(
          path: "/playing-now",
          pageBuilder: (_, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: PlayingNowScreen(),
              transitionsBuilder: pageSlideUpTransition,
            );
          },
        ),
      ],
      builder: (context, state, child) {
        final stringUri = state.uri.toString();
        final isOutsideAppShell =
            stringUri.startsWith("/artist") ||
            stringUri.startsWith("/playlist");
        final isOnPlayingNowScreen = stringUri.startsWith("/playing-now");

        return Scaffold(
          body: Stack(
            children: [
              MusicPlayerInternals(),
              child,
              Center(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isOutsideAppShell
                          ? MediaQuery.of(context).size.height * 0.05
                          : MediaQuery.of(context).size.height * 0.125,
                    ),
                    child: !isOnPlayingNowScreen
                        ? FloatingMusicPlayerPreview()
                        : SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ],
);
