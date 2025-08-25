import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:go_router/go_router.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/music_player_presence_adjuster.dart";
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
  int _activeRouteIndex = 0;

  @override
  void initState() {
    context.read<LocationBloc>().add(LocationFetchEvent());
    context.read<AuthBloc>().add(AuthLocalUserFetchEvent());

    super.initState();
  }

  List<BottomNavigationBarItem> _getBottomNavItems() => [
    BottomNavigationBarItem(
      icon: SvgPicture(
        AssetBytesLoader(
          "assets/vectors/lambda${_activeRouteIndex == 0 ? "" : "-gray"}.svg.vec",
        ),
        height: 45,
        width: 45,
      ),
      label: "",
      tooltip: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.compass),
      label: "",
      tooltip: "Explore",
    ),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.library),
      label: "",
      tooltip: "Your Library",
    ),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.plus),
      label: "",
      tooltip: "Create",
    ),
  ];

  void _onScreenChange(int value) {
    if (_activeRouteIndex == value) {
      return;
    }

    if (value < 3) {
      setState(() => _activeRouteIndex = value);
    }

    switch (value) {
      case 0:
        context.push("/");
        break;
      case 1:
        context.push("/explore");
        break;
      case 2:
        context.push("/library");
        break;
      case 3:
        showModalBottomSheet(
          context: context,
          builder: (context) => PlaylistCreationBottomSheet(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Scaffold(
            appBar: SharedAppBar(),
            drawer: UserInfoDrawer(),
            body: MusicPlayerPresenceAdjuster(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthStateAuthorized) {
                      context.read<LibraryBloc>().add(
                        LibraryPlaylistsFetchEvent(email: state.user.email),
                      );
                    }
                  },
                  builder: (_, __) => widget.child,
                ),
              ),
            ),
            bottomNavigationBar:
                Platform.isIOS
                    ? CupertinoTabBar(
                      height: 80,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey.shade600,
                      currentIndex: _activeRouteIndex,
                      iconSize: 25,
                      onTap: _onScreenChange,
                      items: _getBottomNavItems(),
                    )
                    : BottomNavigationBar(
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey.shade600,
                      currentIndex: _activeRouteIndex,
                      onTap: _onScreenChange,
                      items: _getBottomNavItems(),
                    ),
          ),
        );
      },
    );
  }
}
