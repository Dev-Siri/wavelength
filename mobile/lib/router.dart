import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/screens/home.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/screens/playlists.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        GoRoute(path: "/", builder: (context, state) => HomeScreen()),
        GoRoute(
          path: "/playlists",
          builder: (context, state) => PlaylistsScreen(),
        ),
      ],
      builder: (context, state, child) {
        return Column(
          children: [
            Expanded(child: child),
            BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade600,
              items: [
                BottomNavigationBarItem(
                  icon: Text(
                    "λ",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.plus),
                  label: "Playlists",
                ),
              ],
            ),
          ],
        );
      },
    ),
  ],
);
