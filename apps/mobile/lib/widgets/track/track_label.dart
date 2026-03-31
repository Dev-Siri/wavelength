import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/embedded.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/widgets/explicit_indicator.dart";

class TrackLabel extends StatelessWidget {
  final String title;
  final List<EmbeddedArtist> artists;
  final bool isExplicit;
  final bool showDownloadedBadge;
  final String? playCount;

  const TrackLabel({
    super.key,
    required this.title,
    required this.artists,
    required this.isExplicit,
    this.showDownloadedBadge = false,
    this.playCount,
  });

  @override
  Widget build(BuildContext context) {
    final artistText = formatList(artists.map((artist) => artist.title));
    final playCountText = playCount != null ? " • $playCount" : "";
    final subtext = artistText + playCountText;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.43,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            if (showDownloadedBadge)
              const Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  LucideIcons.circleArrowDown,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            if (isExplicit)
              const Padding(
                padding: EdgeInsets.only(right: 5),
                child: ExplicitIndicator(),
              ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.43,
              child: Text(
                subtext,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
