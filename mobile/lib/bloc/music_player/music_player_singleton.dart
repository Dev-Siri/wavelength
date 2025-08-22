import "package:youtube_player_flutter/youtube_player_flutter.dart";

class MusicPlayerSingleton {
  static final MusicPlayerSingleton _instance =
      MusicPlayerSingleton._internal();

  factory MusicPlayerSingleton() => _instance;

  late final YoutubePlayerController _controller;

  MusicPlayerSingleton._internal() {
    _controller = YoutubePlayerController(
      initialVideoId: "",
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  YoutubePlayerController get controller => _controller;

  void destroy() {
    _controller.dispose();
  }
}
