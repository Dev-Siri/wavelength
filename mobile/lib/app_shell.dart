import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:go_router/go_router.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/version_status.dart";
import "package:wavelength/api/repositories/meta_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/likes/like_count/like_count_bloc.dart";
import "package:wavelength/bloc/likes/like_count/like_count_event.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/music_player_preview.dart";
import "package:wavelength/widgets/playlist_creation_bottom_sheet.dart";
import "package:wavelength/widgets/app_shell_bar.dart";
import "package:wavelength/widgets/update_version_dialog.dart";
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
    super.initState();

    context.read<LocationBloc>().add(LocationFetchEvent());
    context.read<AuthBloc>().add(AuthLocalUserFetchEvent());
    _checkVersionStatus();
  }

  List<BottomNavigationBarItem> _getBottomNavItems() => const [
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.house),
      label: "Home",
      tooltip: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.compass),
      label: "Search",
      tooltip: "Search",
    ),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.library),
      label: "Library",
      tooltip: "Library",
    ),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.plus),
      label: "Create",
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
        context.read<AppBottomSheetBloc>().add(
          AppBottomSheetOpenEvent(
            context: context,
            builder: (context) => const PlaylistCreationBottomSheet(),
          ),
        );
    }
  }

  Future<void> _checkVersionStatus() async {
    void showUpdateVersionDialog(String currentVersion, String latestVersion) =>
        showDialog(
          context: context,
          builder: (context) => UpdateVersionDialog(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
          ),
        );

    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) return;

    final versionStatus = await MetaRepo.fetchVersionStatus();
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    if (versionStatus is ApiResponseSuccess<VersionStatus> &&
        versionStatus.data.latestVersion != appVersion) {
      showUpdateVersionDialog(appVersion, versionStatus.data.latestVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: const AppShellBar(),
              drawer: const UserInfoDrawer(),
              body: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthStateAuthorized) {
                    context.read<LibraryBloc>().add(
                      LibraryFetchEvent(
                        email: state.user.email,
                        authToken: state.authToken,
                      ),
                    );
                    context.read<LikeCountBloc>().add(
                      LikeCountFetchEvent(authToken: state.authToken),
                    );
                  }
                },
                builder: (_, __) => widget.child,
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<AppBottomSheetBloc, AppBottomSheetState>(
                    builder: (context, state) {
                      if (state is AppBottomSheetClosedState) {
                        return const MusicPlayerPreview();
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(splashFactory: NoSplash.splashFactory),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey.shade600,
                      currentIndex: _activeRouteIndex,
                      onTap: _onScreenChange,
                      items: _getBottomNavItems(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
