import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/audio/background_audio_source.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/add_to_playlist_bottom_sheet.dart";

class TopTrackResult extends StatelessWidget {
  final Track track;

  const TopTrackResult({super.key, required this.track});

  Future<void> _playTrack(BuildContext context) async {
    final trackBloc = context.read<MusicPlayerTrackBloc>();
    final queueableMusic = QueueableMusic(
      videoId: track.videoId,
      title: track.title,
      thumbnail: track.thumbnail,
      author: track.author,
      videoType: VideoType.track,
    );

    await MusicPlayerSingleton().player.addAudioSource(
      BackgroundAudioSource(
        track.videoId,
        tag: MediaItem(
          id: track.videoId,
          title: track.title,
          artist: track.author,
          artUri: Uri.parse(track.thumbnail),
          extras: {"videoType": "track"},
        ),
      ),
    );

    trackBloc.add(MusicPlayerTrackLoadEvent(queueableMusic: queueableMusic));
  }

  @override
  Widget build(BuildContext context) {
    final innerUi = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
            builder: (context, state) {
              final isCurrentTrackPlaying =
                  state is MusicPlayerTrackPlayingNowState &&
                  state.playingNowTrack.videoId == track.videoId;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isCurrentTrackPlaying ? 0.5 : 1,
                    child: CachedNetworkImage(
                      imageUrl: getTrackThumbnail(track.videoId),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isCurrentTrackPlaying)
                    const MiniMusicVisualizer(
                      color: Colors.white,
                      animate: true,
                      width: 4,
                      height: 15,
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                track.author,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.read<AppBottomSheetBloc>().add(
                      AppBottomSheetOpenEvent(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (context) => AddToPlaylistBottomSheet(
                          track: Track(
                            videoId: track.videoId,
                            title: track.title,
                            thumbnail: track.thumbnail,
                            author: track.author,
                            duration: track.duration,
                            isExplicit: track.isExplicit,
                          ),
                          videoType: VideoType.track,
                        ),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.circlePlus,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 23, 23),
        borderRadius: BorderRadius.circular(15),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _playTrack(context),
        child: innerUi,
      ),
    );
  }
}
