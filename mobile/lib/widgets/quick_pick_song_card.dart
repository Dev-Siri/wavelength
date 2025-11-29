import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";

class QuickPickSongCard extends StatelessWidget {
  final QuickPicksItem quickPicksItem;

  const QuickPickSongCard({super.key, required this.quickPicksItem});

  Future<void> _playQuickPicksSong(BuildContext context) async {
    final musicTrackBloc = context.read<MusicPlayerTrackBloc>();
    final response = await TrackRepo.fetchTrackDuration(
      trackId: quickPicksItem.videoId,
    );

    if (response is ApiResponseSuccess<int>) {
      musicTrackBloc.add(
        MusicPlayerTrackLoadEvent(
          queueableMusic: QueueableMusic(
            videoId: quickPicksItem.videoId,
            title: quickPicksItem.title,
            thumbnail: quickPicksItem.thumbnail,
            author: quickPicksItem.author,
            duration: Duration(seconds: response.data),
            videoType: VideoType.track,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _playQuickPicksSong(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Colors.grey.shade900,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: quickPicksItem.thumbnail,
                fit: BoxFit.cover,
                height: 130,
                width: (MediaQuery.sizeOf(context).width / 2) - 50,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 130,
              child: Center(
                child: Text(
                  quickPicksItem.title,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: Center(
                child: Text(
                  quickPicksItem.author,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
