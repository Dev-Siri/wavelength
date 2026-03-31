import "package:flutter/material.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class ConfirmationDialog extends StatelessWidget {
  final void Function() onConfirm;
  final String title;
  final String content;

  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(content),
      actions: [
        AmplButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        AmplButton(
          color: Colors.red,
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
