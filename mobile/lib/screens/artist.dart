import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:go_router/go_router.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/artist/artist_bloc.dart";
import "package:wavelength/bloc/artist/artist_event.dart";
import "package:wavelength/bloc/artist/artist_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_presence_adjuster.dart";
import "package:wavelength/widgets/track_tile.dart";

class ArtistScreen extends StatefulWidget {
  final String browseId;

  const ArtistScreen({super.key, required this.browseId});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  final _artistBloc = ArtistBloc();

  @override
  void initState() {
    _artistBloc.add(ArtistFetchEvent(browseId: widget.browseId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: const SvgPicture(
          AssetBytesLoader("assets/vectors/lambda.svg.vec"),
          height: 45,
          width: 45,
        ),
      ),
      body: MusicPlayerPresenceAdjuster(
        child: BlocBuilder<ArtistBloc, ArtistState>(
          bloc: _artistBloc,
          builder: (context, state) {
            if (state is! ArtistSuccessState) {
              if (state is ArtistErrorState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -100),
                      child: Center(
                        child: ErrorMessageDialog(
                          message: "Failed to get artist details from YouTube.",
                          onRetry: () => _artistBloc.add(
                            ArtistFetchEvent(browseId: widget.browseId),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Transform.translate(
                offset: const Offset(0, -100),
                child: const Center(child: LoadingIndicator()),
              );
            }

            return ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 100,
                    foregroundImage: CachedNetworkImageProvider(
                      state.artistExtra.thumbnail,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    state.artist.title,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "${state.artist.subscriberCount} subscribers",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 10),
                  child: Text(
                    "Top Songs",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
                ...state.artist.topSongs.map((final song) {
                  return TrackTile(
                    track: Track(
                      videoId: song.videoId,
                      title: song.title,
                      thumbnail: song.thumbnail,
                      author: song.author,
                      duration: "",
                      isExplicit: song.isExplicit,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
