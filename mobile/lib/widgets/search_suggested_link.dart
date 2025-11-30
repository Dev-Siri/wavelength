import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/search_recommendations.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";

class SearchSuggestedLink extends StatelessWidget {
  final SearchRecommendationItem suggestedLink;

  const SearchSuggestedLink({super.key, required this.suggestedLink});

  Future<void> _handleLinkPress(BuildContext context) async {
    if (suggestedLink.type != "song") return;

    context.read<MusicPlayerTrackBloc>().add(
      MusicPlayerTrackLoadEvent(
        queueableMusic: QueueableMusic(
          videoId: suggestedLink.browseId,
          title: suggestedLink.title,
          thumbnail: suggestedLink.thumbnail,
          author: suggestedLink.meta.authorOrAlbum,
          videoType: VideoType.track,
        ),
      ),
    );

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 26, 26, 26),
      child: ListTile(
        onTap: () => _handleLinkPress(context),
        enabled: true,
        leading: CachedNetworkImage(
          imageUrl: suggestedLink.thumbnail,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
        title: SizedBox(
          width: MediaQuery.sizeOf(context).width - 200,
          child: Text(suggestedLink.title, overflow: TextOverflow.ellipsis),
        ),
        subtitle: Text(
          suggestedLink.subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
