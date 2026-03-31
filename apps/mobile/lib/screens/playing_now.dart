import "dart:ui";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/material.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_bloc.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_event.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_state.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/screens/playing_now_presenters/lyrics_presenter.dart";
import "package:wavelength/screens/playing_now_presenters/playing_now_preview_presenter.dart";
import "package:wavelength/utils/url.dart";
import "package:wavelength/widgets/album/live_album_cover.dart";
import "package:wavelength/widgets/animations/blur_in_animation.dart";
import "package:wavelength/widgets/music_player/music_player_playback_options.dart";
import "package:wavelength/widgets/music_player/music_player_playing_now_background_animated_blobs.dart";

enum PlayingNowPresenter { preview, lyrics }

class PlayingNowScreen extends StatefulWidget {
  const PlayingNowScreen({super.key});

  @override
  State<PlayingNowScreen> createState() => _PlayingNowScreenState();
}

class _PlayingNowScreenState extends State<PlayingNowScreen> {
  PlayingNowPresenter _presentedScreen = PlayingNowPresenter.preview;

  void _switchPresenters() => setState(
    () => _presentedScreen = _presentedScreen == PlayingNowPresenter.preview
        ? PlayingNowPresenter.lyrics
        : PlayingNowPresenter.preview,
  );

  @override
  Widget build(BuildContext context) {
    final musicPlayerTrackBlocState = context
        .read<MusicPlayerTrackBloc>()
        .state;

    final isPlayingNow =
        musicPlayerTrackBlocState is MusicPlayerTrackPlayingNowState;

    return BlocBuilder<CoverEffectColorsBloc, CoverEffectColorsState>(
      builder: (context, state) {
        var color =
            state is CoverEffectColorsSuccessState &&
                _presentedScreen == PlayingNowPresenter.preview
            ? Color.fromRGBO(
                state.colors[0].r,
                state.colors[0].g,
                state.colors[0].b,
                1,
              )
            : Colors.grey.shade900;

        final luminance = color.computeLuminance();
        color = Color.lerp(color, Colors.black, luminance > 0.5 ? 0.3 : 0.0)!;

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;

              if (velocity.abs() < 300) return;

              if (velocity > 0) {
                context.read<WavelengthAudioHandler>().skipToPrevious();
              } else {
                context.read<WavelengthAudioHandler>().skipToNext();
              }
            },
            child: Container(
              decoration: BoxDecoration(color: color),
              height: MediaQuery.sizeOf(context).height,
              child: Stack(
                children: [
                  if (state is CoverEffectColorsSuccessState &&
                      _presentedScreen == PlayingNowPresenter.lyrics)
                    ...state.colors.map(
                      (color) => MusicPlayerPlayingNowBackgroundAnimatedBlobs(
                        color: Color.fromRGBO(color.r, color.g, color.b, 1),
                      ),
                    ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                    child: Container(color: Colors.transparent),
                  ),
                  Opacity(
                    opacity:
                        isPlayingNow &&
                            _presentedScreen != PlayingNowPresenter.lyrics
                        ? 1
                        : 0,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.sizeOf(context).height * 0.3,
                        ),
                        child: Hero(
                          tag: "playing-now-cover",
                          child:
                              BlocBuilder<
                                MusicPlayerTrackBloc,
                                MusicPlayerTrackState
                              >(
                                builder: (context, state) {
                                  if (state
                                      is! MusicPlayerTrackPlayingNowState) {
                                    return const SizedBox.shrink();
                                  }

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: BlurInAnimation(
                                      child: Stack(
                                        children: [
                                          SizedBox.expand(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  getUpscaledTrackThumbnail(
                                                    state
                                                        .playingNowTrack
                                                        .thumbnail,
                                                  ),
                                              memCacheWidth: 512,
                                              memCacheHeight: 512,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (state.playingNowTrack.album !=
                                                  null &&
                                              _presentedScreen ==
                                                  PlayingNowPresenter.preview)
                                            Positioned.fill(
                                              child: ClipRect(
                                                child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                      context,
                                                    ).width,
                                                    height: MediaQuery.sizeOf(
                                                      context,
                                                    ).width,
                                                    child: LiveAlbumCover(
                                                      key: ValueKey(
                                                        state
                                                            .playingNowTrack
                                                            .videoId,
                                                      ),
                                                      videoId: state
                                                          .playingNowTrack
                                                          .videoId,
                                                      albumId: state
                                                          .playingNowTrack
                                                          .album!
                                                          .browseId,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ),
                  ),
                  if (state is CoverEffectColorsSuccessState &&
                      _presentedScreen == PlayingNowPresenter.preview)
                    SizedBox.expand(
                      child: IgnorePointer(
                        child: BlurInAnimation(
                          child: Container(
                            height: MediaQuery.sizeOf(context).height * 0.1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  color.withAlpha(0),
                                  color.withAlpha(51),
                                  color.withAlpha(255),
                                  color.withAlpha(255),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SizedBox.expand(
                      child: _presentedScreen == PlayingNowPresenter.preview
                          ? PlayingNowPreviewPresenter(
                              onTrackChange: (thumbnail) async =>
                                  context.read<CoverEffectColorsBloc>().add(
                                    CoverEffectColorsFetchEvent(
                                      thumbnail: thumbnail,
                                    ),
                                  ),
                            )
                          : const LyricsPresenter(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.15,
                      child: MusicPlayerPlaybackOptions(
                        switchPresenters: _switchPresenters,
                        presentedScreen: _presentedScreen,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.sizeOf(context).height * 0.08,
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.2,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
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
