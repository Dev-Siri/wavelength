import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/utils/format.dart";

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
            artists: quickPicksItem.artists,
            isExplicit: false,
            album: quickPicksItem.album,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: quickPicksItem.thumbnail,
                fit: BoxFit.cover,
              ),
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
                formatList(
                  quickPicksItem.artists.map((artist) => artist.title),
                ),
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
    );
  }
}
