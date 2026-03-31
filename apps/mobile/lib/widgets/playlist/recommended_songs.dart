import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:sliver_tools/sliver_tools.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/bloc/recommended_songs/recommended_songs_bloc.dart";
import "package:wavelength/bloc/recommended_songs/recommended_songs_event.dart";
import "package:wavelength/bloc/recommended_songs/recommended_songs_state.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/track/track_tile.dart";

class RecommendedSongs extends StatefulWidget {
  final String playlistTitle;
  final String playlistId;

  const RecommendedSongs({
    super.key,
    required this.playlistTitle,
    required this.playlistId,
  });

  @override
  State<RecommendedSongs> createState() => _RecommendedSongsState();
}

class _RecommendedSongsState extends State<RecommendedSongs> {
  final recommendedSongsBloc = RecommendedSongsBloc();

  @override
  void initState() {
    super.initState();
    recommendedSongsBloc.add(
      RecommendedSongsFetchEvent(playlistId: widget.playlistId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendedSongsBloc, RecommendedSongsState>(
      bloc: recommendedSongsBloc,
      builder: (context, state) {
        if (state is! RecommendedSongsSuccessState) {
          if (state is RecommendedSongsLoadingState) {
            return MultiSliver(
              children: const [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recommended Songs",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Based on the songs in this playlist.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: LoadingIndicator(),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        }

        final queueableTracks = state.tracks
            .map(
              (track) => QueueableMusic(
                videoId: track.videoId,
                title: track.title,
                thumbnail: track.thumbnail,
                duration: track.duration,
                artists: track.artists,
                album: track.album,
                videoType: VideoType.track,
                isExplicit: track.isExplicit,
              ),
            )
            .toList();
        return MultiSliver(
          children: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recommended Songs",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Based on the songs in this playlist.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = state.tracks[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TrackTile(
                    sourceLabel: widget.playlistTitle,
                    key: ValueKey(song.videoId),
                    track: song,
                    tracks: queueableTracks,
                  ),
                );
              }, childCount: state.tracks.length),
            ),
          ],
        );
      },
    );
  }
}
