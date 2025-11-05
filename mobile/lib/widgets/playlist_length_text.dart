import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";

class PlaylistLengthText extends StatelessWidget {
  final PlaylistTracksLength playlistTracksLength;
  final int trackDownloadedCount;

  const PlaylistLengthText({
    super.key,
    required this.playlistTracksLength,
    required this.trackDownloadedCount,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (playlistTracksLength.songDurationSecond / 60).round();
    final hours = (minutes / 60).round();
    final seconds = playlistTracksLength.songDurationSecond % 60;

    final greaterUnitValue = minutes > 59 ? hours : minutes;
    final greaterUnitText = minutes > 59 ? "hr" : "min";
    final lesserUnitValue = minutes > 59 ? hours : seconds;
    final lesserUnitText = minutes > 59 ? "min" : "sec";
    final songText = playlistTracksLength.songCount == 1 ? "song" : "songs";

    String savedText = "No saves";

    if (trackDownloadedCount == 0) {
      savedText = "No saves";
    } else if (trackDownloadedCount == playlistTracksLength.songCount) {
      savedText = "Saved";
    } else {
      savedText = "$trackDownloadedCount saved";
    }

    if (playlistTracksLength.songCount > 0 &&
        playlistTracksLength.songDurationSecond > 0) {
      return Text(
        "${playlistTracksLength.songCount} $songText, $greaterUnitValue $greaterUnitText $lesserUnitValue $lesserUnitText ($savedText)",
      );
    }

    return const SizedBox();
  }
}
