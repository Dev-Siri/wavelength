import "package:hive/hive.dart";
import "package:wavelength/api/models/lyric.dart";

class LyricAdapter extends TypeAdapter<Lyric> {
  @override
  final int typeId = 2;

  @override
  Lyric read(BinaryReader reader) {
    return Lyric(
      durMs: reader.readInt(),
      startMs: reader.readInt(),
      text: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Lyric obj) {
    writer.writeInt(obj.durMs);
    writer.writeInt(obj.startMs);
    writer.writeString(obj.text);
  }
}
