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
