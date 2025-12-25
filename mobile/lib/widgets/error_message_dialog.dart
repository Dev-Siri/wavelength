import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

class ErrorMessageDialog extends StatelessWidget {
  final String message;
  final void Function()? onRetry;

  const ErrorMessageDialog({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final retryButton = CupertinoButton(
      color: Colors.white,
      onPressed: onRetry,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.rotateCw400, size: 16, color: Colors.black),
          SizedBox(width: 5),
          Text(
            "Try again",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      width: MediaQuery.sizeOf(context).width - 100,
      child: Column(
        children: [
          const Icon(Icons.error),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(message, softWrap: true, textAlign: TextAlign.center),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: retryButton,
            ),
        ],
      ),
    );
  }
}
