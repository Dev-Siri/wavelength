import "package:html_unescape/html_unescape.dart";

String decodeHtmlSpecialChars(String rawText) {
  final unescape = HtmlUnescape();
  final text = unescape.convert(rawText);

  return text;
}
