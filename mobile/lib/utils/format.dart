String bytesToHumanReadableSize(int bytes) {
  if (bytes < 1024) return "$bytes bytes used.";

  if (bytes < 1024 * 1024) {
    return "${(bytes / 1024).toStringAsFixed(2)} KB used.";
  }

  if (bytes < 1024 * 1024 * 1024) {
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB used.";
  }

  return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB used.";
}

String formatList(Iterable<String> items) {
  if (items.isEmpty) return "";
  if (items.length == 1) return items.first;
  if (items.length == 2) return "${items.first} & ${items.elementAt(1)}";

  return "${items.toList().sublist(0, items.length - 1).join(", ")}, & ${items.last}";
}
