import "package:html_unescape/html_unescape.dart";

String decodeHtmlSpecialChars(String rawText) {
  final unescape = HtmlUnescape();
  final text = unescape.convert(rawText);

  return text;
}

String durationify(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  } else {
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}
