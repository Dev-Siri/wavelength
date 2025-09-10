import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shimmer_animation/shimmer_animation.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/playlist/playlist_bloc.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/bloc/playlist/playlist_state.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_bloc.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_event.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_state.dart";
import "package:wavelength/bloc/playlist_theme_color/playlist_theme_color_bloc.dart";
import "package:wavelength/bloc/playlist_theme_color/playlist_theme_color_event.dart";
import "package:wavelength/bloc/playlist_theme_color/playlist_theme_color_state.dart";
import "package:wavelength/screens/edit_playlist.dart";
import "package:wavelength/widgets/brand_cover_image.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_presence_adjuster.dart";
import "package:wavelength/widgets/playlist_length_text.dart";
import "package:wavelength/widgets/playlist_track_tile.dart";
import "package:wavelength/widgets/playlist_visibility_toggle.dart";

class PlaylistScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _playlistThemeColorBloc = PlaylistThemeColorBloc();

  @override
  void initState() {
    context.read<PlaylistBloc>().add(
      PlaylistFetchEvent(playlistId: widget.playlistId),
    );
    context.read<PlaylistLengthBloc>().add(
      PlaylistLengthFetchEvent(playlistId: widget.playlistId),
    );
    super.initState();
  }

  void _playPlaylistTracks(List<PlaylistTrack> playlistTrack) {
    final queueableSongs = playlistTrack
        .map(
          (track) => QueueableMusic(
            videoId: track.videoId,
            title: track.title,
            thumbnail: track.thumbnail,
            author: track.author,
            videoType: track.videoType,
          ),
        )
        .toList();

    context.read<MusicPlayerQueueBloc>().add(
      MusicPlayerReplaceQueueEvent(newQueue: queueableSongs),
    );
    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(queueableMusic: queueableSongs.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is! LibraryFetchSuccessState) {
          return Center(child: LoadingIndicator());
        }

        final playlist = state.playlists.firstWhere(
          (p) => p.playlistId == widget.playlistId,
        );

        _playlistThemeColorBloc.add(
          PlaylistThemeColorFetchEvent(
            playlistImageUrl: playlist.coverImage ?? "",
          ),
        );

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: BackButton(onPressed: () => context.pop()),
            actions: [
              if (Platform.isIOS)
                CupertinoButton(
                  onPressed: () => context.push(
                    "/playlist/${widget.playlistId}/edit",
                    extra: EditPlaylistRouteData(
                      playlistName: playlist.name,
                      coverImage: playlist.coverImage,
                    ),
                  ),
                  child: Icon(LucideIcons.pencil, color: Colors.white),
                )
              else
                IconButton(
                  onPressed: () => context.push(
                    "/playlist/${widget.playlistId}/edit",
                    extra: EditPlaylistRouteData(
                      playlistName: playlist.name,
                      coverImage: playlist.coverImage,
                    ),
                  ),
                  icon: Icon(LucideIcons.pencil, color: Colors.white),
                ),
            ],
          ),
          body: MusicPlayerPresenceAdjuster(
            child: ListView(
              children: [
                BlocBuilder(
                  bloc: _playlistThemeColorBloc,
                  builder: (context, state) {
                    final shadowColor = state is PlaylistThemeColorSuccessState
                        ? Color.fromRGBO(
                            state.playlistThemeColor.r,
                            state.playlistThemeColor.g,
                            state.playlistThemeColor.b,
                            0.8,
                          )
                        : Colors.transparent;

                    return Center(
                      child: BrandCoverImage(
                        imageUrl: playlist.coverImage,
                        shadowColor: shadowColor,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child:
                            BlocBuilder<
                              PlaylistLengthBloc,
                              PlaylistLengthState
                            >(
                              builder: (context, state) {
                                if (state is! PlaylistLengthSuccessState) {
                                  if (state is PlaylistLengthErrorState) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.circleAlert,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "An error occured.",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right:
                                          (MediaQuery.of(context).size.width -
                                              30) /
                                          2,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Shimmer(
                                        child: SizedBox(height: 10),
                                      ),
                                    ),
                                  );
                                }

                                return PlaylistLengthText(
                                  playlistTracksLength:
                                      state.playlistTracksLength,
                                );
                              },
                            ),
                      ),
                      SizedBox(height: 5),
                      Transform.translate(
                        offset: Offset(-3, 0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              foregroundImage: CachedNetworkImageProvider(
                                playlist.authorImage,
                              ),
                            ),
                            SizedBox(width: 7.5),
                            Text(
                              playlist.authorName,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<PlaylistBloc, PlaylistState>(
                  builder: (context, state) {
                    if (state is! PlaylistSuccessState) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: (MediaQuery.of(context).size.height / 4) - 150,
                        ),
                        child: Center(child: LoadingIndicator()),
                      );
                    }

                    final orderedSongs = [...state.songs];

                    orderedSongs.sort(
                      (a, b) =>
                          a.positionInPlaylist.compareTo(b.positionInPlaylist),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    _playPlaylistTracks(orderedSongs),
                                icon: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(LucideIcons.play),
                                ),
                              ),
                            ),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state is! AuthStateAuthorized ||
                                    state.user.email !=
                                        playlist.authorGoogleEmail) {
                                  return SizedBox.shrink();
                                }

                                return PlaylistVisibilityToggle(
                                  playlistId: playlist.playlistId,
                                  isInitiallyPrivate: !playlist.isPublic,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        for (final song in orderedSongs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PlaylistTrackTile(playlistTrack: song),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
