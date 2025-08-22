import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";

class QuickPickSongCard extends StatelessWidget {
  final QuickPicksItem quickPicksItem;

  const QuickPickSongCard({super.key, required this.quickPicksItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => context.read<MusicPlayerTrackBloc>().add(
            MusicPlayerTrackLoadEvent(
              queueableMusic: QueueableMusic(
                videoId: quickPicksItem.videoId,
                title: quickPicksItem.title,
                thumbnail: quickPicksItem.thumbnail,
                author: quickPicksItem.author,
                videoType: VideoType.track,
              ),
            ),
          ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey.shade900,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: quickPicksItem.thumbnail,
                fit: BoxFit.cover,
                height: 130,
                width: (MediaQuery.of(context).size.width / 2) - 50,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 130,
              child: Center(
                child: Text(
                  quickPicksItem.title,
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: Center(
                child: Text(
                  quickPicksItem.author,
                  style: TextStyle(
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
