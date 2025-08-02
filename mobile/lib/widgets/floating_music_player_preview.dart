import "package:flutter/cupertino.dart";

class FloatingMusicPlayerPreview extends StatelessWidget {
  const FloatingMusicPlayerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      width: MediaQuery.of(context).size.width - 50,
      child: Placeholder(),
    );
  }
}
