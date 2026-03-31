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

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbColor: _dragValue != null
                ? Colors.white.withAlpha(128)
                : Colors.white,
            overlayColor: Colors.white.withAlpha(51),
            trackHeight: 4,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withAlpha(77),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            min: 0,
            max: totalSeconds > 0 ? totalSeconds : 1,
            value:
                _dragValue ??
                widget.position.inSeconds.toDouble().clamp(
                  0,
                  widget.duration.inSeconds.toDouble(),
                ),
            onChanged: (value) => setState(() => _dragValue = value),
            onChangeEnd: (value) {
              setState(() => _dragValue = null);
              widget.onSeek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  durationify(widget.position),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "-${durationify(widget.duration - widget.position)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
