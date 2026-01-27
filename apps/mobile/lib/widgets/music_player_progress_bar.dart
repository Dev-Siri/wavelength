import "package:flutter/material.dart";
import "package:wavelength/utils/parse.dart";

class MusicPlayerProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const MusicPlayerProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<MusicPlayerProgressBar> createState() => _MusicPlayerProgressBarState();
}

class _MusicPlayerProgressBarState extends State<MusicPlayerProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.duration.inSeconds.toDouble();
    final currentSeconds =
        _dragValue ??
        widget.position.inSeconds.toDouble().clamp(0, totalSeconds);

    return Column(
      children: [
        Slider(
          min: 0,
          max: totalSeconds > 0 ? totalSeconds : 1,
          value: currentSeconds,
          thumbColor: Colors.white,
          activeColor: Colors.white,
          onChanged: (value) => setState(() => _dragValue = value),
          onChangeEnd: (value) {
            setState(() => _dragValue = null);
            widget.onSeek(Duration(seconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(durationify(widget.duration)),
              Text("-${durationify(widget.duration - widget.position)}"),
            ],
          ),
        ),
      ],
    );
  }
}
