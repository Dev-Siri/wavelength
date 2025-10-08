import "dart:math" as math;

import "package:go_router/go_router.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/api/repositories/image_repo.dart";
import "package:wavelength/screens/playing_now_presenters/lyrics_presenter.dart";
import "package:wavelength/screens/playing_now_presenters/playing_now_preview_presenter.dart";
import "package:wavelength/utils/url.dart";

enum PlayingNowPresenter { preview, lyrics }

class PlayingNowScreen extends StatefulWidget {
  const PlayingNowScreen({super.key});

  @override
  State<PlayingNowScreen> createState() => _PlayingNowScreenState();
}

class _PlayingNowScreenState extends State<PlayingNowScreen> {
  PlayingNowPresenter _presentedScreen = PlayingNowPresenter.preview;
  Color? _trackThemeColor;

  Future<void> _fetchTrackThemeColor(String videoId) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final trackThemeColorKey = "$videoId-t_color";
    final trackColor = sharedPrefs.getStringList(trackThemeColorKey);

    if (trackColor != null) {
      final r = int.parse(trackColor[0]);
      final g = int.parse(trackColor[1]);
      final b = int.parse(trackColor[2]);

      _trackThemeColor = Color.fromRGBO(r, g, b, 1);
      return;
    }

    final colorResponse = await ImageRepo.fetchImageThemeColor(
      url: getTrackThumbnail(videoId),
    );

    if (colorResponse is ApiResponseSuccess<ThemeColor>) {
      final themeRgb = colorResponse.data;

      await sharedPrefs.setStringList(trackThemeColorKey, [
        themeRgb.r.toString(),
        themeRgb.g.toString(),
        themeRgb.b.toString(),
      ]);

      setState(
        () => _trackThemeColor = Color.fromRGBO(
          themeRgb.r,
          themeRgb.g,
          themeRgb.b,
          1,
        ),
      );
    }
  }

  void _switchPresenters() => setState(
    () => _presentedScreen = _presentedScreen == PlayingNowPresenter.preview
        ? PlayingNowPresenter.lyrics
        : PlayingNowPresenter.preview,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      color: _trackThemeColor ?? Colors.black,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Transform.rotate(
            angle: math.pi / -2,
            child: BackButton(onPressed: () => context.pop()),
          ),
          actions: [
            IconButton(
              onPressed: _switchPresenters,
              icon: Icon(
                _presentedScreen == PlayingNowPresenter.preview
                    ? LucideIcons.micVocal
                    : LucideIcons.squarePlay,
              ),
              tooltip: _presentedScreen == PlayingNowPresenter.preview
                  ? "Lyrics"
                  : "Playing Now",
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _presentedScreen == PlayingNowPresenter.preview
              ? PlayingNowPreviewPresenter(
                  onTrackChange: (trackId) => _fetchTrackThemeColor(trackId),
                )
              : const LyricsPresenter(),
        ),
      ),
    );
  }
}
