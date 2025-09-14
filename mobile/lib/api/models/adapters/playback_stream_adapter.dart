import "package:hive/hive.dart";
import "package:wavelength/api/models/playback_stream.dart";

class PlaybackStreamAdapter extends TypeAdapter<PlaybackStream> {
  @override
  final int typeId = 3;

  @override
  PlaybackStream read(BinaryReader reader) {
    return PlaybackStream(
      abr: reader.readDouble(),
      duration: reader.readInt(),
      ext: reader.readString(),
      url: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PlaybackStream obj) {
    writer.writeDouble(obj.abr);
    writer.writeInt(obj.duration);
    writer.writeString(obj.ext);
    writer.writeString(obj.url);
  }
}
