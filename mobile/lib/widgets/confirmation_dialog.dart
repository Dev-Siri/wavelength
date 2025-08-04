import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

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
    final cancelButtonInnerUi = const Text(
      "Cancel",
      style: TextStyle(color: Colors.white),
    );
    final confirmButtonInnerUi = const Text(
      "Confirm",
      style: TextStyle(color: Colors.white),
    );

    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(content),
      actions: [
        if (Platform.isIOS)
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: cancelButtonInnerUi,
          )
        else
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: cancelButtonInnerUi,
          ),
        if (Platform.isIOS)
          CupertinoButton(
            color: Colors.red,
            borderRadius: BorderRadius.zero,
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: confirmButtonInnerUi,
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: confirmButtonInnerUi,
          ),
      ],
    );
  }
}
