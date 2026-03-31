import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

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
        "You are on v$currentVersion, but the latest version is v$latestVersion. Update to the latest version to ensure Wavelength continues to work without issues.",
      ),
      actions: [
        AmplButton(
          onPressed: () {
            _updateApp();
            Navigator.of(context).pop();
          },
          color: Colors.blue,
          child: updateButtonInnerUi,
        ),
        AmplButton(
          onPressed: () => Navigator.of(context).pop(),
          child: laterButtonInnerUi,
        ),
      ],
    );
  }
}
