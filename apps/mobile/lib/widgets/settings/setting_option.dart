import "package:flutter/material.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class SettingOption extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? modifier;
  final void Function()? onPressed;

  const SettingOption({
    super.key,
    required this.title,
    this.description,
    this.modifier,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onPressed != null) const SizedBox(height: 4),
                  if (description != null)
                    Text(
                      description!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(left: 16), child: modifier),
          ],
        ),
      ),
    );

    if (onPressed != null) {
      return AmplButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed!,
        child: content,
      );
    }

    return content;
  }
}
