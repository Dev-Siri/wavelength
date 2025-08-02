import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/utils/parse.dart";

class PlaylistTrackTile extends StatelessWidget {
  final PlaylistTrack playlistTrack;

  const PlaylistTrackTile({super.key, required this.playlistTrack});

  Future<void> _playSong() {
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final innerUi = Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: playlistTrack.thumbnail,
              fit: BoxFit.cover,
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 1.4) - 50,
                child: Text(
                  decodeHtmlSpecialChars(playlistTrack.title),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                playlistTrack.author,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _playSong,
        child: innerUi,
      );
    } else {
      return MaterialButton(onPressed: _playSong, child: innerUi);
    }
  }
}
