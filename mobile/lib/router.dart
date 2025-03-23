import "package:go_router/go_router.dart";
import "package:wavelength/app_shell.dart";
import "package:wavelength/screens/home.dart";
import "package:wavelength/screens/library.dart";
import "package:wavelength/screens/playlists.dart";
import "package:wavelength/screens/search.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        GoRoute(path: "/", builder: (_, __) => HomeScreen()),
        GoRoute(path: "/playlists", builder: (_, __) => PlaylistsScreen()),
        GoRoute(path: "/library", builder: (_, __) => LibraryScreen()),
        GoRoute(path: "/search", builder: (_, __) => SearchScreen()),
      ],
      builder: (_, __, child) {
        return AppShell(child: child);
      },
    ),
  ],
);
