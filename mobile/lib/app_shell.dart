import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:go_router/go_router.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/widgets/playlist_creation_bottom_sheet.dart";
import "package:wavelength/widgets/shared_app_bar.dart";
import "package:wavelength/widgets/user_info_drawer.dart";

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int activeRouteIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Scaffold(
        appBar: SharedAppBar(),
        drawer: UserInfoDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: widget.child,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade600,
          currentIndex: activeRouteIndex,
          onTap: (value) {
            if (value < 2) {
              setState(() => activeRouteIndex = value);
            }

            switch (value) {
              case 0:
                context.go("/");
                break;
              case 1:
                context.go("/playlists");
                break;
              case 2:
                showModalBottomSheet(
                  context: context,
                  builder: (context) => PlaylistCreationBottomSheet(),
                );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture(
                AssetBytesLoader(
                  "assets/vectors/lambda${activeRouteIndex == 0 ? "" : "-gray"}.svg.vec",
                ),
                height: 45,
                width: 45,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.compass),
              label: "Discover Playlists",
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.plus),
              label: "Create",
            ),
          ],
        ),
      ),
    );
  }
}
