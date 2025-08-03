import "package:flutter/cupertino.dart";
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
import "package:wavelength/screens/playlist.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        GoRoute(path: "/", builder: (_, __) => HomeScreen()),
        GoRoute(
          path: "/explore",
          builder:
              (_, __) => MultiBlocProvider(
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                // make it slide up the screen
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
