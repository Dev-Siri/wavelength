import "package:hive/hive.dart";
import "package:wavelength/api/models/playlist_track.dart";

VideoType _safeVideoType(int index) {
  if (index >= 0 && index < VideoType.values.length) {
    return VideoType.values[index];
  }

  return VideoType.values.first;
}

class PlaylistTrackAdapter extends TypeAdapter<PlaylistTrack> {
  @override
  final int typeId = 0;

  @override
  PlaylistTrack read(BinaryReader reader) {
    return PlaylistTrack(
      playlistTrackId: reader.readString(),
      title: reader.readString(),
      thumbnail: reader.readString(),
      positionInPlaylist: reader.readInt(),
      isExplicit: reader.readBool(),
      author: reader.readString(),
      duration: reader.readString(),
      videoId: reader.readString(),
      videoType: _safeVideoType(reader.readInt()),
      playlistId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistTrack obj) {
    writer.writeString(obj.playlistTrackId);
    writer.writeString(obj.title);
    writer.writeString(obj.thumbnail);
    writer.writeInt(obj.positionInPlaylist);
    writer.writeBool(obj.isExplicit);
    writer.writeString(obj.author);
    writer.writeString(obj.duration);
    writer.writeString(obj.videoId);
    writer.writeInt(obj.videoType.index);
    writer.writeString(obj.playlistId);
  }
}
