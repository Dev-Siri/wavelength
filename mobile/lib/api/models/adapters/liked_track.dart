import "package:hive/hive.dart";
import "package:wavelength/api/models/adapters/playlist_track_adapter.dart";
import "package:wavelength/api/models/liked_track.dart";

class LikedTrackAdapter extends TypeAdapter<LikedTrack> {
  @override
  final int typeId = 3;

  @override
  LikedTrack read(BinaryReader reader) {
    return LikedTrack(
      likeId: reader.readString(),
      title: reader.readString(),
      thumbnail: reader.readString(),
      email: reader.readString(),
      isExplicit: reader.readBool(),
      author: reader.readString(),
      duration: reader.readString(),
      videoId: reader.readString(),
      videoType: safeVideoType(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, LikedTrack obj) {
    writer.writeString(obj.likeId);
    writer.writeString(obj.title);
    writer.writeString(obj.thumbnail);
    writer.writeString(obj.email);
    writer.writeBool(obj.isExplicit);
    writer.writeString(obj.author);
    writer.writeString(obj.duration);
    writer.writeString(obj.videoId);
    writer.writeInt(obj.videoType.index);
  }
}
