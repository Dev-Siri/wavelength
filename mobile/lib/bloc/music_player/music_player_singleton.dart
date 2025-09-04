import "dart:io";

import "package:http/io_client.dart";
import "package:youtube_explode_dart/youtube_explode_dart.dart";
import "package:just_audio/just_audio.dart";

class MusicPlayerSingleton {
  static final MusicPlayerSingleton _instance =
      MusicPlayerSingleton._internal();

  factory MusicPlayerSingleton() => _instance;

  late final AudioPlayer _player;
  late final YoutubeExplode _yt;

  MusicPlayerSingleton._internal() {
    if (Platform.isIOS) {
      _yt = YoutubeExplode();
      _player = AudioPlayer();
      return;
    }

    final httpClient = HttpClient();

    httpClient.userAgent =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36";

    final customIoClient = IOClient(httpClient);
    final customHttpClient = YoutubeHttpClient(customIoClient);

    _yt = YoutubeExplode(customHttpClient);
    _player = AudioPlayer();
  }

  AudioPlayer get player => _player;
  YoutubeExplode get yt => _yt;

  void destroy() {
    _yt.close();
    _player.dispose();
  }
}
