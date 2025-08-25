import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wavelength/bloc/artist/artist_bloc.dart";
import "package:wavelength/bloc/artist/artist_event.dart";
import "package:wavelength/bloc/artist/artist_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/loading_indicator.dart";
import "package:wavelength/widgets/music_player_presence_adjuster.dart";

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

  Future<void> _openArtistOnYouTube() async {
    final url = "https://youtube.com/channel/${widget.browseId}";
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
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
                      offset: Offset(0, -100),
                      child: Center(
                        child: ErrorMessageDialog(
                          message: "Failed to get artist details from YouTube.",
                          onRetry:
                              () => _artistBloc.add(
                                ArtistFetchEvent(browseId: widget.browseId),
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Transform.translate(
                offset: Offset(0, -100),
                child: Center(child: LoadingIndicator()),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 100,
                    foregroundImage: CachedNetworkImageProvider(
                      state.artistExtra.items[0].snippet.thumbnails.high.url ??
                          "",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    state.artist.title,
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "${state.artist.subscriberCount} subscribers",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 5,
                  ),
                  child:
                      Platform.isIOS
                          ? CupertinoButton(
                            onPressed: _openArtistOnYouTube,
                            color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.youtube, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "View artist on YouTube.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                          : MaterialButton(
                            onPressed: _openArtistOnYouTube,
                            color: Colors.red,
                            padding: EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.youtube,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "View artist on YouTube.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
