import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:wavelength/api/models/stream_download.dart";
import "package:wavelength/utils/parse.dart";

class QueuedTrackTile extends StatelessWidget {
  final StreamDownload queuedDownload;

  const QueuedTrackTile({super.key, required this.queuedDownload});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          FractionallySizedBox(
            widthFactor: queuedDownload.progress / 100,
            child: Container(height: 60, color: Colors.grey.withAlpha(38)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: queuedDownload.metadata.thumbnail,
                    height: 45,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width / 2) + 40,
                      child: Text(
                        decodeHtmlSpecialChars(queuedDownload.metadata.title),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width / 2),
                      child: Text(
                        decodeHtmlSpecialChars(queuedDownload.metadata.author),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  queuedDownload.progress == 0
                      ? "In Queue"
                      : "${queuedDownload.progress.toStringAsFixed(2)}%",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
