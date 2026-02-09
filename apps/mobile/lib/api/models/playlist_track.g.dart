// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistTrackAdapter extends TypeAdapter<PlaylistTrack> {
  @override
  final int typeId = 0;

  @override
  PlaylistTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistTrack(
      playlistTrackId: fields[0] as String,
      title: fields[1] as String,
      thumbnail: fields[2] as String,
      positionInPlaylist: fields[3] as int,
      isExplicit: fields[4] as bool,
      artists: (fields[5] as List).cast<EmbeddedArtist>(),
      duration: fields[6] as int,
      videoId: fields[7] as String,
      videoType: fields[8] as VideoType,
      playlistId: fields[9] as String,
      album: fields[10] as EmbeddedAlbum?,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistTrack obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.playlistTrackId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.positionInPlaylist)
      ..writeByte(4)
      ..write(obj.isExplicit)
      ..writeByte(5)
      ..write(obj.artists)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.videoId)
      ..writeByte(8)
      ..write(obj.videoType)
      ..writeByte(9)
      ..write(obj.playlistId)
      ..writeByte(10)
      ..write(obj.album);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
