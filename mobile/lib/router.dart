import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/app_shell.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_bloc.dart";
import "package:wavelength/screens/home.dart";
import "package:wavelength/screens/library.dart";
import "package:wavelength/screens/explore.dart";

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
  ],
);
