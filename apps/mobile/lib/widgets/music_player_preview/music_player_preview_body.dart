import "package:cached_network_image/cached_network_image.dart";
import "package:text_scroll/text_scroll.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/audio_device_service.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/bloc/audio_device/audio_device_bloc.dart";
import "package:wavelength/bloc/audio_device/audio_device_state.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_event.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_state.dart";
import "package:wavelength/utils/audio_icon.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/widgets/animations/shimmer_animation.dart";
import "package:wavelength/widgets/connected_output_device_label.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class MusicPlayerPreviewBody extends StatelessWidget {
  final QueueableMusic playingNowTrack;

  const MusicPlayerPreviewBody({super.key, required this.playingNowTrack});

  @override
  Widget build(BuildContext context) {
    final upperArtistText =
        " • ${formatList(playingNowTrack.artists.map((artist) => artist.title))}";
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: "playing-now-cover",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: playingNowTrack.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<AudioDeviceBloc, AudioDeviceState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (state is AudioDeviceAvailableState &&
                            state.device.type != AudioDeviceType.speaker)
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.595,
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: playingNowTrack.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (state.device.type !=
                                      AudioDeviceType.speaker)
                                    TextSpan(
                                      text: upperArtistText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        else
                          TextScroll(
                            playingNowTrack.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    if (state is AudioDeviceAvailableState &&
                        state.device.type != AudioDeviceType.speaker)
                      ShimmerAnimation(
                        duration: const Duration(seconds: 2),
                        child: Row(
                          children: [
                            Icon(getAudioIcon(state.device.type), size: 11),
                            const SizedBox(width: 4),
                            TextScroll(
                              state.device.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              fadedBorder: true,
                              mode: TextScrollMode.endless,
                              velocity: const Velocity(
                                pixelsPerSecond: Offset(20, 0),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        formatList(
                          playingNowTrack.artists.map((artist) => artist.title),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(10, 0),
            child: const ConnectedOutputDeviceLabel(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child:
                BlocBuilder<
                  MusicPlayerPlaystateBloc,
                  MusicPlayerPlaystateState
                >(
                  builder: (context, state) {
                    final isMusicPlaying =
                        state is MusicPlayerPlaystatePlayingState;

                    return AmplIconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => context
                          .read<MusicPlayerPlaystateBloc>()
                          .add(MusicPlayerPlaystateToggleEvent()),
                      icon: Icon(
                        isMusicPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
