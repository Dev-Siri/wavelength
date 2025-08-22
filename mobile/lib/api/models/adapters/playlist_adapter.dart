import "package:hive/hive.dart";
import "package:wavelength/api/models/playlist.dart";

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1;

  @override
  Playlist read(BinaryReader reader) {
    return Playlist(
      playlistId: reader.readString(),
      name: reader.readString(),
      authorGoogleEmail: reader.readString(),
      authorName: reader.readString(),
      authorImage: reader.readString(),
      coverImage: reader.read() as String?,
      isPublic: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer.writeString(obj.playlistId);
    writer.writeString(obj.name);
    writer.writeString(obj.authorGoogleEmail);
    writer.writeString(obj.authorName);
    writer.writeString(obj.authorImage);
    writer.write(obj.coverImage);
    writer.writeBool(obj.isPublic);
  }
}
