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

Duration parseToDuration(String input) {
  final parts = input.split(":").map(int.parse).toList();

  if (parts.length == 3) {
    final hours = parts[0];
    final minutes = parts[1];
    final seconds = parts[2];
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  } else if (parts.length == 2) {
    final minutes = parts[0];
    final seconds = parts[1];
    return Duration(minutes: minutes, seconds: seconds);
  } else {
    throw FormatException("Invalid duration format: $input");
  }
}
