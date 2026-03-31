import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/app_shell.dart";
import "package:wavelength/bloc/album/album_bloc.dart";
import "package:wavelength/bloc/likes/liked_tracks/liked_tracks_bloc.dart";
import "package:wavelength/bloc/likes/liked_tracks_playlength/liked_tracks_playlength_bloc.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/search/albums/albums_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_bloc.dart";
import "package:wavelength/root.dart";
import "package:wavelength/screens/album.dart";
import "package:wavelength/screens/artist.dart";
import "package:wavelength/screens/downloads.dart";
import "package:wavelength/screens/edit_playlist.dart";
import "package:wavelength/screens/home.dart";
import "package:wavelength/screens/library.dart";
import "package:wavelength/screens/explore.dart";
import "package:wavelength/screens/likes.dart";
import "package:wavelength/screens/playlist.dart";
import "package:wavelength/screens/settings.dart";
import "package:wavelength/screens/settings/audio_quality.dart";
import "package:wavelength/screens/settings/download_quality.dart";
import "package:wavelength/screens/settings/streaming_preference.dart";
import "package:wavelength/screens/settings/cellular_streaming_quality.dart";
import "package:wavelength/screens/settings/wifi_streaming_quality.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        ShellRoute(
          routes: [
            GoRoute(path: "/", builder: (_, _) => const HomeScreen()),
            GoRoute(
              path: "/explore",
              builder: (_, _) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => PublicPlaylistsBloc()),
                  BlocProvider(create: (_) => TracksBloc()),
                  BlocProvider(create: (_) => VideosBloc()),
                  BlocProvider(create: (_) => ArtistsBloc()),
                  BlocProvider(create: (_) => AlbumsBloc()),
                ],
                child: const ExploreScreen(),
              ),
            ),
            GoRoute(path: "/library", builder: (_, _) => const LibraryScreen()),
          ],
          builder: (_, _, child) {
            return AppShell(child: child);
          },
        ),
        GoRoute(
          path: "/playlist/:id",
          builder: (_, state) {
            final id = state.pathParameters["id"]!;
            return PlaylistScreen(playlistId: id);
          },
        ),
        GoRoute(
          path: "/playlist/:id/edit",
          builder: (_, state) {
            final id = state.pathParameters["id"]!;
            final isRouteDataValid = state.extra is EditPlaylistRouteData;

            return isRouteDataValid
                ? EditPlaylistScreen(
                    playlistId: id,
                    routeData: state.extra as EditPlaylistRouteData,
                  )
                : const SizedBox.shrink();
          },
        ),
        GoRoute(
          path: "/likes",
          builder: (_, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => LikedTracksBloc()),
                BlocProvider(create: (_) => LikedTracksPlaylengthBloc()),
              ],
              child: const LikesScreen(),
            );
          },
        ),
        GoRoute(
          path: "/artist/:id",
          builder: (_, state) {
            final id = state.pathParameters["id"]!;
            return ArtistScreen(browseId: id);
          },
        ),
        GoRoute(
          path: "/album/:id",
          builder: (_, state) {
            final id = state.pathParameters["id"]!;
            return BlocProvider(
              create: (_) => AlbumBloc(),
              child: AlbumScreen(browseId: id),
            );
          },
        ),
        GoRoute(path: "/downloads", builder: (_, _) => const DownloadsScreen()),
        GoRoute(path: "/settings", builder: (_, _) => const SettingsScreen()),
        GoRoute(
          path: "/settings/streaming-preference",
          builder: (_, _) => const StreamingPreferenceSetting(),
        ),
        GoRoute(
          path: "/settings/audio-quality",
          builder: (_, _) => const AudioQualitySetting(),
        ),
        GoRoute(
          path: "/settings/audio-quality/streaming/cellular",
          builder: (_, _) => const CellularStreamingQualitySetting(),
        ),
        GoRoute(
          path: "/settings/audio-quality/streaming/wifi",
          builder: (_, _) => const WifiStreamingQualitySetting(),
        ),
        GoRoute(
          path: "/settings/audio-quality/downloads",
          builder: (_, _) => const DownloadQualitySetting(),
        ),
      ],
      builder: (context, state, child) {
        return Root(uri: state.uri.toString(), child: child);
      },
    ),
  ],
);
