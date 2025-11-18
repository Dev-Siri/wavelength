import "package:wavelength/constants.dart";

String getTrackThumbnail(String videoId) {
  return "$ytImgApiUrl/vi/$videoId/maxresdefault.jpg";
}

enum StreamPlaybackType { audio, video }
