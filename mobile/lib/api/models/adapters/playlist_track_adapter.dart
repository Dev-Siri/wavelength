import "package:hive/hive.dart";
import "package:wavelength/api/models/playlist_track.dart";

class PlaylistTrackAdapter extends TypeAdapter<PlaylistTrack> {
  @override
  final int typeId = 0;

  @override
  PlaylistTrack read(BinaryReader reader) {
    return PlaylistTrack(
      playlistTrackId: reader.toString(),
      title: reader.toString(),
      thumbnail: reader.toString(),
      positionInPlaylist: reader.readInt(),
      isExplicit: reader.readBool(),
      author: reader.toString(),
      duration: reader.toString(),
      videoId: reader.toString(),
      videoType: VideoType.values[reader.readInt()],
      playlistId: reader.toString(),
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
