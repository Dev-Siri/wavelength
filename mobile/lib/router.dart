import "package:go_router/go_router.dart";
import "package:wavelength/app_shell.dart";
import "package:wavelength/screens/home.dart";
import "package:wavelength/screens/playlists.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        GoRoute(path: "/", builder: (_, __) => HomeScreen()),
        GoRoute(path: "/playlists", builder: (_, __) => PlaylistsScreen()),
      ],
      builder: (_, __, child) {
        return AppShell(child: child);
      },
    ),
  ],
);
