import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wavelength/constants.dart";

class UpdateVersionDialog extends StatelessWidget {
  final String latestVersion;
  final String currentVersion;

  const UpdateVersionDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
  });

  Future<void> _updateApp() => launchUrl(Uri.parse(appUpdateUrl));

  @override
  Widget build(BuildContext context) {
    final laterButtonInnerUi = const Text(
      "Later",
      style: TextStyle(color: Colors.white),
    );

    final updateButtonInnerUi = const Text(
      "Update",
      style: TextStyle(color: Colors.white),
    );

    return AlertDialog.adaptive(
      title: const Text("Update Available"),
      content: Text(
        "You are on v$currentVersion, but the latest version is $latestVersion. Update to the latest version to ensure Wavelength continues to work without issues.",
      ),
      actions: [
        if (Platform.isIOS)
          CupertinoButton(
            onPressed: () {
              _updateApp();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.zero,
            color: Colors.blue,
            child: updateButtonInnerUi,
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              _updateApp();
              Navigator.of(context).pop();
            },
            child: updateButtonInnerUi,
          ),
        if (Platform.isIOS)
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: laterButtonInnerUi,
          )
        else
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: laterButtonInnerUi,
          ),
      ],
    );
  }
}
