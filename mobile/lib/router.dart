import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/app_shell.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_bloc.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_bloc.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_bloc.dart";
import "package:wavelength/root.dart";
import "package:wavelength/screens/artist.dart";
import "package:wavelength/screens/downloads.dart";
import "package:wavelength/screens/edit_playlist.dart";
import "package:wavelength/screens/home.dart";
import "package:wavelength/screens/library.dart";
import "package:wavelength/screens/explore.dart";
import "package:wavelength/screens/likes.dart";
import "package:wavelength/screens/playing_now.dart";
import "package:wavelength/screens/playlist.dart";
import "package:wavelength/screens/settings.dart";
import "package:wavelength/transitions.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        ShellRoute(
          routes: [
            GoRoute(path: "/", builder: (_, __) => const HomeScreen()),
            GoRoute(
              path: "/explore",
              builder: (_, __) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => PublicPlaylistsBloc()),
                  BlocProvider(create: (_) => TracksBloc()),
                  BlocProvider(create: (_) => VideosBloc()),
                  BlocProvider(create: (_) => ArtistsBloc()),
                ],
                child: const ExploreScreen(),
              ),
            ),
            GoRoute(
              path: "/library",
              builder: (_, __) => const LibraryScreen(),
            ),
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
          path: "/playlist/:id/edit",
          pageBuilder: (_, state) {
            final id = state.pathParameters["id"]!;
            final isRouteDataValid = state.extra is EditPlaylistRouteData;

            return CustomTransitionPage(
              key: state.pageKey,
              child: isRouteDataValid
                  ? EditPlaylistScreen(
                      playlistId: id,
                      routeData: state.extra as EditPlaylistRouteData,
                    )
                  : const SizedBox.shrink(),
              transitionsBuilder: pageSlideUpTransition,
            );
          },
        ),
        GoRoute(
          path: "/likes",
          pageBuilder: (_, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => LikedTracksBloc()),
                  BlocProvider(create: (_) => LikedTracksPlaylengthBloc()),
                ],
                child: const LikesScreen(),
              ),
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
              child: const PlayingNowScreen(),
              transitionsBuilder: pageSlideUpTransition,
            );
          },
        ),
        GoRoute(
          path: "/downloads",
          builder: (_, __) => const DownloadsScreen(),
        ),
        GoRoute(path: "/settings", builder: (_, __) => const SettingsScreen()),
      ],
      builder: (context, state, child) {
        return Root(uri: state.uri.toString(), child: child);
      },
    ),
  ],
);
