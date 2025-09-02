import "package:youtube_explode_dart/youtube_explode_dart.dart";
import "package:just_audio/just_audio.dart";

class MusicPlayerSingleton {
  static final MusicPlayerSingleton _instance =
      MusicPlayerSingleton._internal();

  factory MusicPlayerSingleton() => _instance;

  late final AudioPlayer _player;
  late final YoutubeExplode _yt;

  MusicPlayerSingleton._internal() {
    _yt = YoutubeExplode();
    _player = AudioPlayer();
  }

  AudioPlayer get player => _player;
  YoutubeExplode get yt => _yt;

  void destroy() {
    _yt.close();
    _player.dispose();
  }
}
