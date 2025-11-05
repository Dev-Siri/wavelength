import "package:just_audio/just_audio.dart";

class MusicPlayerSingleton {
  static final MusicPlayerSingleton _instance =
      MusicPlayerSingleton._internal();

  factory MusicPlayerSingleton() => _instance;

  late final AudioPlayer _player;

  MusicPlayerSingleton._internal() {
    _player = AudioPlayer(androidOffloadSchedulingEnabled: true);
  }

  AudioPlayer get player => _player;

  void destroy() => _player.dispose();
}
