String getUpscaledTrackThumbnail(String thumbnail) {
  return thumbnail
      .replaceFirst("h120-", "h1024-")
      .replaceFirst("w120-", "w1024-");
}
